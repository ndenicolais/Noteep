// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/audio_note.dart';
import '../../models/note_model.dart';
import '../../providers/notes_provider.dart';
import '../../providers/notes_undo_redo_provider.dart';
import '../../utils/notification_service.dart';

/// Owns [NoteEditorScreen]'s note state and every Firestore/notification
/// mutation, so the widget only holds text/focus controllers and UI. Callers
/// are expected to wrap fire-and-forget futures returned here (e.g. [save])
/// with `notifyOnError` for user-facing error feedback, same as everywhere
/// else in the app.
class NoteEditorController extends ChangeNotifier {
  NoteEditorController({required WidgetRef ref, required NoteModel initialNote})
    : _ref = ref,
      _note = initialNote {
    _isNew = ref.read(notesProvider).every((n) => n.id != initialNote.id);
  }

  final WidgetRef _ref;
  NoteModel _note;
  late bool _isNew;
  bool _isSaving = false;
  bool _softDeleted = false;

  NoteModel get note => _note;
  bool get isSaving => _isSaving;
  bool get softDeleted => _softDeleted;

  bool _isEmpty(String title, String content) {
    if (title.trim().isNotEmpty || content.trim().isNotEmpty) return false;
    if (_note.type == NoteType.checklist) {
      return _note.checklistItems.every((i) => i.text.trim().isEmpty);
    }
    return true;
  }

  /// Persists the current note (with [title]/[content] trimmed in), adding
  /// it if this is a brand-new note. No-ops if the note was soft-deleted, or
  /// if it's new and still empty.
  Future<void> save(String title, String content) async {
    if (_softDeleted) return;
    if (_isNew && _isEmpty(title, content)) return;

    final updated = _note.copyWith(
      title: title.trim(),
      content: content.trim(),
      updatedAt: DateTime.now(),
    );

    final Future<void> pending;
    if (_isNew) {
      pending = _ref.read(notesProvider.notifier).addNote(updated);
      _isNew = false;
    } else {
      pending = _ref.read(notesProvider.notifier).updateNote(updated);
    }
    _note = updated;
    _isSaving = true;
    notifyListeners();

    try {
      await pending;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Applies [update] to the current note and notifies listeners, without
  /// persisting — callers still need to call [save] afterwards.
  void updateNote(NoteModel Function(NoteModel current) update) {
    _note = update(_note);
    notifyListeners();
  }

  // ─── Reminder ─────────────────────────────────────────────────────────────

  Future<void> scheduleReminderNotification(DateTime scheduled) {
    final content = _note.content;
    return NotificationService.instance.scheduleNotification(
      id: NotificationService.idForNote(_note.id),
      title: _note.title.isEmpty ? 'Promemoria nota' : _note.title,
      body:
          content.isEmpty
              ? 'Hai un promemoria per questa nota'
              : content.substring(0, content.length > 80 ? 80 : content.length),
      scheduledAt: scheduled,
    );
  }

  Future<void> cancelReminderNotification() {
    return NotificationService.instance.cancelNotification(
      NotificationService.idForNote(_note.id),
    );
  }

  // ─── Undo / Redo ──────────────────────────────────────────────────────────

  /// Applies the next undo step (if any) and returns the resulting note, or
  /// null if there was nothing to undo.
  NoteModel? performUndo() {
    final undone = NoteUndoRedoManager.performUndo(_ref, _note.id, _note);
    if (undone != null) {
      _note = undone;
      notifyListeners();
    }
    return undone;
  }

  /// Applies the next redo step (if any) and returns the resulting note, or
  /// null if there was nothing to redo.
  NoteModel? performRedo() {
    final redone = NoteUndoRedoManager.performRedo(_ref, _note.id, _note);
    if (redone != null) {
      _note = redone;
      notifyListeners();
    }
    return redone;
  }

  // ─── Audio notes ──────────────────────────────────────────────────────────

  void addAudioNote(AudioNote audioNote) {
    updateNote(
      (n) => n.copyWith(audioNotes: [...n.audioNotes, audioNote]),
    );
  }

  void removeAudioNote(String audioNoteId) {
    updateNote(
      (n) => n.copyWith(
        audioNotes: n.audioNotes.where((a) => a.id != audioNoteId).toList(),
      ),
    );
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> delete() {
    _softDeleted = true;
    return _ref.read(notesProvider.notifier).deleteNote(_note.id);
  }
}
