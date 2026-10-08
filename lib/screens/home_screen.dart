// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../core/routing/app_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_version.dart';
import '../models/note_model.dart';
import '../providers/calendar_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/settings/backup_provider.dart';
import '../providers/settings/ui_provider.dart';
import '../utils/backup_service.dart';
import '../utils/changelog_service.dart';
import '../screens/note_template_screen.dart';
import '../screens/home/speed_dial_fab.dart';
import '../screens/home/reorderable_grid_view.dart';
import '../screens/home/reorderable_list_view.dart';
import '../widgets/changelog_dialog.dart';
import '../widgets/nav_scaffold.dart';
import '../widgets/sort_sheet.dart';
import '../widgets/shared/empty_state.dart';
import '../widgets/shared/pull_to_refresh.dart';
import '../widgets/shared/search_field.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowChangelog();
      _maybeRunAutoBackup();
    });
  }

  Future<void> _maybeShowChangelog() async {
    final pending = await ChangelogService.pendingEntries(
      ref.read(sharedPreferencesProvider),
      appVersion,
    );
    if (pending.isEmpty || !mounted) return;
    await showChangelogDialog(context, entries: pending);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Creates a local backup if automatic backup is enabled in Settings and
  /// it's due per the configured frequency. Runs once per app open — this
  /// app has no OS-level background scheduler wired up, so "automatic" means
  /// "checked whenever you open the app" rather than a true background job.
  Future<void> _maybeRunAutoBackup() async {
    if (kIsWeb) return; // BackupService needs dart:io / path_provider.
    final settings = ref.read(backupSettingsProvider);
    if (!settings.enabled) return;
    if (!await BackupService.isBackupDue(settings.frequency)) return;

    final path = await BackupService.createBackup(
      notesData: {
        'notes': ref.read(notesProvider).map((n) => n.toJson()).toList(),
      },
      tasksData: {
        'tasks': ref.read(tasksProvider).map((t) => t.toJson()).toList(),
        'taskLists':
            ref.read(taskListsProvider).map((l) => l.toJson()).toList(),
      },
      calendarData: {
        'calendar': ref.read(calendarProvider).map((e) => e.toJson()).toList(),
      },
    );
    if (path != null) {
      await BackupService.setLastBackupTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(homeLayoutProvider);
    final notes = ref.watch(filteredNotesProvider);
    final sortOrder = ref.watch(sortOrderProvider);
    final loadError = ref.watch(notesLoadErrorProvider);
    final isLoading = ref.watch(notesLoadingProvider);

    return NavScaffold(
      section: DrawerSection.home,
      titleWidget: SearchField(
        controller: _searchController,
        provider: searchQueryProvider,
        hintText: 'Cerca nelle note...',
      ),
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () => _showSortSheet(context, sortOrder),
          tooltip: 'Ordina note',
        ),
      ],
      body:
          notes.isEmpty && isLoading && loadError == null
              ? const Center(child: CircularProgressIndicator())
              : PullToRefresh(
                onRefresh: ref.read(notesProvider.notifier).reload,
                childIsScrollable: notes.isNotEmpty,
                child: _buildNotes(notes, layout, loadError),
              ),
      floatingActionButton: SpeedDialFab(
        onNoteTap: () => _openEditor(NoteType.note),
        onChecklistTap: () => _openEditor(NoteType.checklist),
        onTaskTap: () {
          AppNav.openTasks(context);
        },
        onAudioNoteTap: _openAudioNote,
        onTemplateTap: _openFromTemplate,
      ),
    );
  }

  Widget _buildNotes(
    List<NoteModel> notes,
    HomeLayout layout,
    Object? loadError,
  ) {
    if (notes.isEmpty) {
      if (loadError != null) {
        return EmptyState(
          icon: Icons.cloud_off,
          message:
              'Errore di sincronizzazione. Verifica la connessione e riprova.',
          actionLabel: 'Riprova',
          actionIcon: Icons.refresh,
          onAction: ref.read(notesProvider.notifier).reload,
        );
      }
      // Empty because of the search query: creating a note wouldn't help.
      final hasNotes = ref.read(activeNotesProvider).isNotEmpty;
      return EmptyState(
        icon: Icons.note_alt_outlined,
        message: hasNotes ? 'Nessuna nota trovata' : 'Ancora nessuna nota',
        actionLabel: hasNotes ? null : 'Crea la prima nota',
        actionIcon: Icons.add,
        onAction: () => _openEditor(NoteType.note),
      );
    }
    return layout == HomeLayout.grid
        ? ReorderableGridView(
          notes: notes,
          onReorder: (from, to) {
            ref.read(sortOrderProvider.notifier).state = SortOrder.custom;
            ref
                .read(notesProvider.notifier)
                .reorderNotes(notes, from, from < to ? to + 1 : to);
          },
        )
        : ReorderableListViewWidget(
          notes: notes,
          onReorder: (oldIndex, newIndex) {
            ref.read(sortOrderProvider.notifier).state = SortOrder.custom;
            ref
                .read(notesProvider.notifier)
                .reorderNotes(notes, oldIndex, newIndex);
          },
        );
  }

  void _openEditor(NoteType type) {
    AppNav.openNote(context, NoteModel(type: type));
  }

  void _openAudioNote() {
    AppNav.openNote(
      context,
      NoteModel(type: NoteType.note),
      autoOpenRecorder: true,
    );
  }

  Future<void> _openFromTemplate() async {
    final template = await showNoteTemplateSheet(context);
    if (template == null || !mounted) return;
    final note = NoteModel(
      type: template.type,
      content: template.content,
      checklistItems:
          template.checklistItems
              .map(
                (text) => ChecklistItem(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  text: text,
                ),
              )
              .toList(),
    );
    AppNav.openNote(context, note);
  }

  void _showSortSheet(BuildContext context, SortOrder current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SortSheet(
            current: current,
            onChanged: (s) {
              ref.read(sortOrderProvider.notifier).state = s;
              Navigator.pop(context);
            },
          ),
    );
  }
}
