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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/calendar_provider.dart';
import '../widgets/nav_scaffold.dart';
import '../widgets/note_card.dart';
import '../widgets/shared/empty_state.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(archivedNotesProvider);
    final tasks = ref.watch(archivedTasksProvider);
    final events = ref.watch(archivedEventsProvider);
    final notesLoadError = ref.watch(notesLoadErrorProvider);
    final tasksLoadError = ref.watch(tasksLoadErrorProvider);

    return NavScaffold(
      section: DrawerSection.archive,
      titleWidget: const Text('Archivio'),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: 'Note'), Tab(text: 'Task'), Tab(text: 'Eventi')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _NoteList(notes: notes, loadError: notesLoadError),
                  _TaskList(tasks: tasks, loadError: tasksLoadError),
                  _EventList(events: events),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteList extends StatelessWidget {
  const _NoteList({required this.notes, this.loadError});
  final List<dynamic> notes;
  final Object? loadError;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return EmptyState(
        icon: loadError != null ? Icons.cloud_off : Icons.note_alt_outlined,
        message:
            loadError != null
                ? 'Errore di sincronizzazione. Verifica la connessione e riprova.'
                : 'Nessuna nota archiviata',
        iconSize: 64,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => NoteCard(note: notes[i]),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.tasks, this.loadError});
  final List<dynamic> tasks;
  final Object? loadError;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return EmptyState(
        icon: loadError != null ? Icons.cloud_off : Icons.task_alt,
        message:
            loadError != null
                ? 'Errore di sincronizzazione. Verifica la connessione e riprova.'
                : 'Nessun task archiviato',
        iconSize: 64,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final task = tasks[i];
        return Card(
          child: ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: const Icon(Icons.archive_outlined),
          ),
        );
      },
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({required this.events});
  final List<dynamic> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy,
        message: 'Nessun evento archiviato',
        iconSize: 64,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final event = events[i];
        return Card(
          child: ListTile(
            title: Text(event.title),
            subtitle: Text(event.description),
            trailing: const Icon(Icons.archive_outlined),
          ),
        );
      },
    );
  }
}
