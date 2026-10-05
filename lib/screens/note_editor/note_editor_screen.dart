// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
// NoteEditorScreen now only handles Notes and Checklists
import '../../models/audio_note.dart';
import '../../models/note_model.dart';
import '../../models/change_history.dart';
import '../../providers/notes_provider.dart';
import '../../providers/notes_undo_redo_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/audio_service.dart';
import '../../utils/note_lock_service.dart';
import '../../widgets/reminder_banner.dart';
import '../../widgets/shared/error_feedback.dart';
import '../../widgets/style_editor/color_picker_widget.dart';
import '../../widgets/style_editor/style_editor_sheet.dart';
import 'note_audio_notes_section.dart';
import 'note_audio_recorder_sheet.dart';
import 'note_checklist_editor.dart';
import 'note_editor_app_bar.dart';
import 'note_editor_bottom_bar.dart';
import 'note_editor_controller.dart';
import 'note_link_sheet.dart';
import 'note_linked_notes_section.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({
    super.key,
    required this.note,
    this.autoOpenRecorder = false,
  });
  final NoteModel note;

  /// When true, immediately opens the audio recorder sheet once the screen
  /// is shown — used by the "Audio" quick-create action.
  final bool autoOpenRecorder;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late NoteEditorController _controller;
  late TextEditingController _contentController;
  late TextEditingController _titleController;
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;
  bool _isApplyingUndoRedo = false;
  bool _markdownMode = false;
  String _lastTitle = '';
  String _lastContent = '';

  NoteModel get _note => _controller.note;

  @override
  void initState() {
    super.initState();
    _controller = NoteEditorController(ref: ref, initialNote: widget.note);
    _controller.addListener(_onControllerChanged);

    _titleController = TextEditingController(text: _note.title);
    _contentController = TextEditingController(text: _note.content);

    _lastTitle = _titleController.text;
    _lastContent = _contentController.text;

    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();

    _titleFocusNode.addListener(_onTitleFocusChanged);
    _contentFocusNode.addListener(_onContentFocusChanged);
    _titleController.addListener(_onTitleTextChanged);
    _contentController.addListener(_onContentTextChanged);

    if (widget.autoOpenRecorder) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openAudioRecorder());
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _titleController.removeListener(_onTitleTextChanged);
    _contentController.removeListener(_onContentTextChanged);
    _titleFocusNode.removeListener(_onTitleFocusChanged);
    _contentFocusNode.removeListener(_onContentFocusChanged);
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onTitleFocusChanged() {
    if (!_titleFocusNode.hasFocus && !_isApplyingUndoRedo) {
      _commitTitleChange(_titleController.text);
    }
  }

  void _onContentFocusChanged() {
    if (!_contentFocusNode.hasFocus && !_isApplyingUndoRedo) {
      _commitContentChange(_contentController.text);
    }
  }

  void _onTitleTextChanged() {
    if (_isApplyingUndoRedo) return;
    final current = _titleController.text;
    if (_endsWithWordBoundary(current)) {
      _commitTitleChange(current);
    }
  }

  void _onContentTextChanged() {
    if (_isApplyingUndoRedo) return;
    final current = _contentController.text;
    if (_endsWithWordBoundary(current)) {
      _commitContentChange(current);
    }
  }

  bool _endsWithWordBoundary(String text) {
    if (text.isEmpty) return false;
    final last = text[text.length - 1];
    return last == ' ' ||
        last == '\n' ||
        last == '.' ||
        last == ',' ||
        last == '!' ||
        last == '?' ||
        last == ';' ||
        last == ':';
  }

  void _commitTitleChange(String newTitle) {
    if (newTitle == _lastTitle) return;
    ref
        .read(noteChangeHistoryProvider(_note.id).notifier)
        .addChange(NoteTitleChange(oldTitle: _lastTitle, newTitle: newTitle));
    _lastTitle = newTitle;
  }

  void _commitContentChange(String newContent) {
    if (newContent == _lastContent) return;
    ref
        .read(noteChangeHistoryProvider(_note.id).notifier)
        .addChange(NoteTextChange(oldText: _lastContent, newText: newContent));
    _lastContent = newContent;
  }

  void _save() {
    notifyOnError(
      _controller.save(_titleController.text, _contentController.text),
      context,
    );
  }

  // ─── Share ────────────────────────────────────────────────────────────────

  void _shareNote() {
    final title = _note.title.trim();
    final content =
        _note.type == NoteType.checklist
            ? _note.checklistItems
                .map((i) => '${i.isChecked ? '☑' : '☐'} ${i.text}')
                .join('\n')
            : _note.content.trim();

    final text = [
      if (title.isNotEmpty) title,
      if (content.isNotEmpty) content,
    ].join('\n\n');

    if (text.isEmpty) return;
    Share.share(text);
  }

  // ─── Reminder ─────────────────────────────────────────────────────────────

  Future<void> _setReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _note.reminder ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _note.reminder ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null || !mounted) return;

    final scheduled = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    _controller.updateNote((n) => n.copyWith(reminder: scheduled));
    _save();

    try {
      await _controller.scheduleReminderNotification(scheduled);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossibile pianificare il promemoria.'),
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Promemoria: ${DateFormat('dd MMM, HH:mm').format(scheduled)}',
          ),
        ),
      );
    }
  }

  Future<void> _removeReminder() async {
    await _controller.cancelReminderNotification();
    _controller.updateNote((n) => n.copyWith(clearReminder: true));
    _save();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Promemoria rimosso')));
    }
  }

  // ─── Lock ─────────────────────────────────────────────────────────────────

  Future<void> _toggleLock() async {
    if (_note.isLocked) {
      final ok = await NoteLockService.instance.authenticate();
      if (!ok) return;
    } else if (!await NoteLockService.instance.canAuthenticate()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Il blocco nota non è disponibile su questa piattaforma.',
            ),
          ),
        );
      }
      return;
    }
    _controller.updateNote((n) => n.copyWith(isLocked: !n.isLocked));
    _save();
  }

  // ─── Undo / Redo ──────────────────────────────────────────────────────────

  void _performUndo() {
    _isApplyingUndoRedo = true;
    final undoneNote = _controller.performUndo();
    if (undoneNote != null) {
      _titleController.text = undoneNote.title;
      _contentController.text = undoneNote.content;
      _lastTitle = undoneNote.title;
      _lastContent = undoneNote.content;
    }
    _isApplyingUndoRedo = false;
  }

  void _performRedo() {
    _isApplyingUndoRedo = true;
    final redoneNote = _controller.performRedo();
    if (redoneNote != null) {
      _titleController.text = redoneNote.title;
      _contentController.text = redoneNote.content;
      _lastTitle = redoneNote.title;
      _lastContent = redoneNote.content;
    }
    _isApplyingUndoRedo = false;
  }

  // ─── Linked notes ─────────────────────────────────────────────────────────

  void _showLinkNoteDialog() {
    final allNotes =
        ref.read(activeNotesProvider).where((n) => n.id != _note.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => NoteLinkSheet(
            allNotes: allNotes,
            linkedIds: _note.linkedNoteIds,
            onToggle: (noteId) {
              _controller.updateNote((n) {
                final current = List<String>.from(n.linkedNoteIds);
                if (current.contains(noteId)) {
                  current.remove(noteId);
                } else {
                  current.add(noteId);
                }
                return n.copyWith(linkedNoteIds: current);
              });
              _save();
            },
          ),
    );
  }

  // ─── Style helpers ────────────────────────────────────────────────────────

  TextStyle _titleStyle(BuildContext context) {
    final s = _note.style;
    final effectiveFg = s.fontColor ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      color: s.titleFontColor ?? effectiveFg,
      fontFamily: s.titleFontFamily ?? s.fontFamily,
      fontSize: s.titleFontSize ?? (s.fontSize + 4),
      fontWeight: (s.titleIsBold ?? true) ? FontWeight.bold : FontWeight.normal,
      fontStyle:
          (s.titleIsItalic ?? false) ? FontStyle.italic : FontStyle.normal,
    );
  }

  TextStyle _contentStyle(BuildContext context) {
    final s = _note.style;
    final effectiveFg = s.fontColor ?? Theme.of(context).colorScheme.onSurface;
    return TextStyle(
      color: effectiveFg,
      fontFamily: s.fontFamily,
      fontSize: s.fontSize,
      fontWeight: s.isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: s.isItalic ? FontStyle.italic : FontStyle.normal,
      decoration:
          s.isStrikethrough ? TextDecoration.lineThrough : TextDecoration.none,
      decorationColor: s.isStrikethrough ? effectiveFg : null,
      decorationThickness: s.isStrikethrough ? 2.0 : null,
    );
  }

  void _openStyleEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => StyleEditorSheet(
            style: _note.style,
            onChanged: (newStyle) {
              _controller.updateNote((n) => n.copyWith(style: newStyle));
              _save();
            },
          ),
    );
  }

  void _openBackgroundPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Scegli Colore Sfondo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ColorPickerWidget(
                  current:
                      _note.style.backgroundColor ??
                      Theme.of(context).colorScheme.surface,
                  isDark: isDark,
                  onPick: (color) {
                    _controller.updateNote(
                      (n) => n.copyWith(
                        style: n.style.copyWith(backgroundColor: color),
                      ),
                    );
                    _save();
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
    );
  }

  // ─── Audio notes ──────────────────────────────────────────────────────────

  Future<void> _openAudioRecorder() async {
    final recorded = await showModalBottomSheet<AudioNote>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AudioRecorderSheet(),
    );
    if (recorded == null) return;
    _controller.addAudioNote(recorded);
    _save();
  }

  void _deleteAudioNote(AudioNote audioNote) {
    _controller.removeAudioNote(audioNote.id);
    _save();
    AudioRecordingService().deleteAudioFile(audioNote.filepath);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Elimina nota'),
            content: const Text('Vuoi spostare questa nota nel cestino?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  final pending = _controller.delete();
                  if (pending != null) {
                    notifyWithUndo(
                      pending,
                      context,
                      message: 'Nota spostata nel cestino',
                      onUndo: _controller.restore,
                    );
                  }
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Text(
                  'Elimina',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _note.style;
    final effectiveBg =
        s.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final effectiveFg = s.fontColor ?? Theme.of(context).colorScheme.onSurface;
    // uiFg is contrast-aware for the background, independent of content text color
    final uiFg = AppColors.contrastingTextColor(effectiveBg);
    final hasReminder = _note.reminder != null;
    final linkedNotes =
        ref
            .watch(activeNotesProvider)
            .where((n) => _note.linkedNoteIds.contains(n.id))
            .toList();

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _save();
      },
      child: Scaffold(
        backgroundColor: effectiveBg,
        appBar: NoteEditorAppBar(
          note: _note,
          effectiveBg: effectiveBg,
          uiFg: uiFg,
          isSaving: _controller.isSaving,
          markdownMode: _markdownMode,
          onToggleMarkdown:
              () => setState(() => _markdownMode = !_markdownMode),
          onToggleLock: _toggleLock,
          onUndo: _performUndo,
          onRedo: _performRedo,
          onPin: () {
            _controller.updateNote((n) => n.copyWith(isPinned: !n.isPinned));
            _save();
          },
          onArchive: () {
            _controller.updateNote(
              (n) => n.copyWith(isArchived: !n.isArchived),
            );
            _save();
            Navigator.pop(context);
          },
          onShare: _shareNote,
        ),
        body: Column(
          children: [
            if (hasReminder)
              ReminderBanner(
                reminder: _note.reminder!,
                onTap: _setReminder,
                onRemove: _removeReminder,
              ),
            // Campo Titolo
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                style: _titleStyle(context),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Titolo',
                  hintStyle: _titleStyle(context).copyWith(
                    color: (s.titleFontColor ?? effectiveFg).withAlpha(80),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            // Area Contenuto (Nota o Checklist)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  if (_note.type == NoteType.checklist)
                    NoteChecklistEditor(
                      items: _note.checklistItems,
                      textStyle: _contentStyle(context),
                      onChanged: (items) {
                        _controller.updateNote(
                          (n) => n.copyWith(checklistItems: items),
                        );
                        _save();
                      },
                    )
                  else if (_markdownMode)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MarkdownBody(
                        data: _contentController.text,
                        styleSheet: MarkdownStyleSheet.fromTheme(
                          Theme.of(context),
                        ).copyWith(p: _contentStyle(context)),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _contentController,
                        focusNode: _contentFocusNode,
                        style: _contentStyle(context),
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: 'Nota',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  if (_note.linkedNoteIds.isNotEmpty)
                    NoteLinkedNotesSection(linkedNotes: linkedNotes),
                  if (_note.audioNotes.isNotEmpty)
                    NoteAudioNotesSection(
                      audioNotes: _note.audioNotes,
                      onDelete: _deleteAudioNote,
                    ),
                ],
              ),
            ),
            // Footer con data ultima modifica
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'Ultima modifica: ${DateFormat('dd MMM, HH:mm').format(_note.updatedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: effectiveFg.withAlpha(150),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: NoteEditorBottomBar(
          effectiveBg: effectiveBg,
          uiFg: uiFg,
          hasReminder: hasReminder,
          isChecklist: _note.type == NoteType.checklist,
          onBackgroundPicker: _openBackgroundPicker,
          onStyleEditor: _openStyleEditor,
          onReminder: _setReminder,
          onLinkNote: _showLinkNoteDialog,
          onRecordAudio: _openAudioRecorder,
          onAddChecklistItem: () {
            _controller.updateNote(
              (n) => n.copyWith(
                checklistItems: [...n.checklistItems, ChecklistItem(text: '')],
              ),
            );
            _save();
          },
          onDelete: _confirmDelete,
        ),
      ),
    );
  }
}
