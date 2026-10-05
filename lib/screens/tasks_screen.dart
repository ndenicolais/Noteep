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
import '../models/task_model.dart';
import '../models/task_list_model.dart';
import '../providers/tasks_provider.dart';
import '../providers/settings/ui_provider.dart';
import '../widgets/nav_scaffold.dart';
import '../widgets/sort_sheet.dart';
import '../widgets/shared/empty_state.dart';
import '../widgets/shared/pull_to_refresh.dart';
import '../widgets/shared/swipe_actions.dart';
import '../widgets/shared/error_feedback.dart';
import '../widgets/shared/search_field.dart';
import '../utils/dialogs/move_to_list_dialog.dart';
import 'task_editor/task_editor_screen.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final TextEditingController _quickAddTaskController = TextEditingController();
  final FocusNode _quickAddFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _quickAddTaskController.dispose();
    _quickAddFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addTask(BuildContext screenContext) {
    final text = _quickAddTaskController.text.trim();
    if (text.isNotEmpty) {
      final tabController = DefaultTabController.of(screenContext);
      final tabIndex = tabController.index;
      final taskLists = ref.read(taskListsProvider);

      final currentListId =
          tabIndex > 1
              ? (tabIndex - 2 < taskLists.length
                  ? taskLists[tabIndex - 2].id
                  : null)
              : null;

      final newTask = TaskModel(
        title: text,
        listId: currentListId,
        isSpecial: tabIndex == 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      notifyOnError(
        ref.read(tasksProvider.notifier).addTask(newTask),
        screenContext,
      );
      _quickAddTaskController.clear();
      _quickAddFocusNode.unfocus();
    }
  }

  void _showAddTaskDialog(BuildContext screenContext) {
    showDialog(
      context: screenContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuovo Task'),
          content: TextField(
            controller: _quickAddTaskController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Cosa devi fare?'),
            onSubmitted: (_) {
              _addTask(screenContext);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                _addTask(screenContext);
                Navigator.pop(context);
              },
              child: const Text('Aggiungi'),
            ),
          ],
        );
      },
    );
  }

  void _showSortSheet(BuildContext context, WidgetRef ref) {
    final current = ref.read(taskSortOrderProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SortSheet(
            current: current,
            onChanged: (s) {
              ref.read(taskSortOrderProvider.notifier).state = s;
              Navigator.pop(context);
            },
          ),
    );
  }

  void _showCreateListDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nuovo Elenco'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Nome elenco'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    ref
                        .read(taskListsProvider.notifier)
                        .addList(TaskListModel(name: name));
                  }
                  Navigator.pop(context);
                },
                child: const Text('Crea'),
              ),
            ],
          ),
    );
  }

  void _deleteCurrentList(BuildContext screenContext) {
    final tabController = DefaultTabController.of(screenContext);
    final tabIndex = tabController.index;
    if (tabIndex <= 1) return;
    final taskLists = ref.read(taskListsProvider);
    if (tabIndex - 2 >= taskLists.length) return;
    final list = taskLists[tabIndex - 2];
    showDialog(
      context: screenContext,
      builder:
          (context) => AlertDialog(
            title: const Text('Elimina Elenco'),
            content: Text('Vuoi davvero eliminare l\'elenco "${list.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  // Jump away from this tab first: deleting the list shrinks
                  // the tab count, and leaving the controller on an index
                  // that no longer exists throws a RangeError.
                  tabController.animateTo(0);
                  ref.read(taskListsProvider.notifier).deleteList(list.id);
                  Navigator.pop(context);
                },
                child: const Text('Elimina'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskLists = ref.watch(taskListsProvider);
    final totalTabs = 2 + taskLists.length;

    return DefaultTabController(
      length: totalTabs,
      child: Builder(
        builder: (buildContext) {
          return NavScaffold(
            section: DrawerSection.tasks,
            titleWidget: SearchField(
              controller: _searchController,
              provider: taskSearchQueryProvider,
              hintText: 'Cerca tra i task...',
            ),
            appBarActions: [
              ListenableBuilder(
                listenable: DefaultTabController.of(buildContext),
                builder: (context, _) {
                  final currentIndex = DefaultTabController.of(context).index;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (currentIndex > 1)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteCurrentList(buildContext),
                          tooltip: 'Elimina elenco',
                        ),
                      IconButton(
                        icon: const Icon(Icons.sort),
                        onPressed: () => _showSortSheet(buildContext, ref),
                        tooltip: 'Ordina task',
                      ),
                      IconButton(
                        icon: const Icon(Icons.playlist_add),
                        onPressed: _showCreateListDialog,
                        tooltip: 'Nuovo elenco',
                      ),
                    ],
                  );
                },
              ),
            ],
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddTaskDialog(buildContext),
              child: const Icon(Icons.add),
            ),
            body: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: [
                    const Tab(text: 'Tutte'),
                    const Tab(text: 'Speciali'),
                    ...taskLists.map((l) => Tab(text: l.name)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _TaskList(source: filteredTasksProvider),
                      _TaskList(source: specialTasksProvider),
                      ...taskLists.map(
                        (l) => _TaskList(source: taskListTasksProvider(l.id)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  final ProviderListenable<List<TaskModel>> source;
  const _TaskList({required this.source});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(source);
    final sort = ref.watch(taskSortOrderProvider);

    // Sort tasks: uncompleted first, then by the active sort order — explicit
    // tie-break instead of relying on `tasks` already being ordered, since
    // Dart's List.sort isn't guaranteed stable for equal elements.
    final sortedTasks = List<TaskModel>.from(tasks);
    sortedTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      switch (sort) {
        case SortOrder.createdNewest:
          return b.createdAt.compareTo(a.createdAt);
        case SortOrder.createdOldest:
          return a.createdAt.compareTo(b.createdAt);
        case SortOrder.modifiedNewest:
          return b.updatedAt.compareTo(a.updatedAt);
        case SortOrder.modifiedOldest:
          return a.updatedAt.compareTo(b.updatedAt);
        case SortOrder.custom:
          return 0;
      }
    });

    final completedTasks = sortedTasks.where((t) => t.isCompleted).toList();
    final activeTasks = sortedTasks.where((t) => !t.isCompleted).toList();

    // Task-list failures surface through tasksLoadErrorProvider on the tasks
    // reload, which hits the same backend, so they are not reported twice.
    Future<void> refresh() => Future.wait([
      ref.read(tasksProvider.notifier).reload(),
      ref.read(taskListsProvider.notifier).reload().catchError((_) {}),
    ]);

    if (tasks.isEmpty) {
      final loadError = ref.watch(tasksLoadErrorProvider);
      final isLoading = ref.watch(tasksLoadingProvider);
      if (isLoading && loadError == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return PullToRefresh(
        onRefresh: refresh,
        // No "create" action: the quick-add field is always visible above.
        child: EmptyState(
          icon: loadError != null ? Icons.cloud_off : Icons.task_alt,
          message:
              loadError != null
                  ? 'Errore di sincronizzazione. Verifica la connessione e riprova.'
                  : 'Nessun task trovato',
          actionLabel: loadError != null ? 'Riprova' : null,
          actionIcon: Icons.refresh,
          onAction: refresh,
        ),
      );
    }

    return PullToRefresh(
      onRefresh: refresh,
      childIsScrollable: true,
      child: _buildList(activeTasks, completedTasks),
    );
  }

  Widget _buildList(
    List<TaskModel> activeTasks,
    List<TaskModel> completedTasks,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (activeTasks.isNotEmpty) ...[
          ...activeTasks.map(
            (task) => _TaskItem(key: ValueKey(task.id), task: task),
          ),
        ],
        if (completedTasks.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          const Text(
            'Completati',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...completedTasks.map(
            (task) => _TaskItem(key: ValueKey(task.id), task: task),
          ),
        ],
      ],
    );
  }
}

void _confirmDeleteTask(BuildContext context, WidgetRef ref, TaskModel task) {
  showDialog<void>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: const Text('Elimina task'),
          content: Text('Vuoi spostare "${task.title}" nel cestino?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                final notifier = ref.read(tasksProvider.notifier);
                notifyWithUndo(
                  notifier.softDelete(task.id),
                  context,
                  message: 'Task spostato nel cestino',
                  onUndo: () => notifier.restoreFromTrash(task.id),
                );
                Navigator.pop(ctx);
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

class _TaskItem extends ConsumerWidget {
  final TaskModel task;
  const _TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(tasksProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    return SwipeActions(
      id: task.id,
      start: SwipeAction(
        icon: task.isCompleted ? Icons.undo : Icons.check,
        label: task.isCompleted ? 'Riapri' : 'Completa',
        color: Colors.green,
        // A completed task stays in the list (or is hidden by the
        // "show completed" setting), so the row snaps back.
        removesItem: false,
        onTriggered:
            () => notifyWithUndo(
              notifier.toggleComplete(task.id),
              context,
              message: task.isCompleted ? 'Task riaperto' : 'Task completato',
              onUndo: () => notifier.toggleComplete(task.id),
            ),
      ),
      end: SwipeAction(
        icon: Icons.delete_outline,
        label: 'Cestino',
        color: cs.error,
        onTriggered:
            () => notifyWithUndo(
              notifier.softDelete(task.id),
              context,
              message: 'Task spostato nel cestino',
              onUndo: () => notifier.restoreFromTrash(task.id),
            ),
      ),
      child: _buildTile(context, ref),
    );
  }

  Widget _buildTile(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskEditorScreen(task: task)),
        );
      },
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) {
          notifyOnError(
            ref.read(tasksProvider.notifier).toggleComplete(task.id),
            context,
          );
        },
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? Colors.grey : null,
        ),
      ),
      subtitle:
          task.description.isNotEmpty
              ? Text(
                task.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: task.isCompleted ? Colors.grey : null),
              )
              : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              task.isSpecial ? Icons.star : Icons.star_border,
              color: task.isSpecial ? Colors.amber : null,
            ),
            onPressed: () {
              ref.read(tasksProvider.notifier).toggleSpecial(task.id);
            },
            tooltip:
                task.isSpecial
                    ? 'Rimuovi dagli speciali'
                    : 'Aggiungi agli speciali',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskEditorScreen(task: task),
                  ),
                );
              } else if (value == 'move') {
                showMoveToListDialog(
                  context: context,
                  ref: ref,
                  currentListId: task.listId,
                  onListSelected: (listId) {
                    ref
                        .read(tasksProvider.notifier)
                        .moveToList(task.id, listId);
                  },
                );
              } else if (value == 'delete') {
                _confirmDeleteTask(context, ref, task);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Modifica')),
                  const PopupMenuItem(
                    value: 'move',
                    child: Text('Sposta in elenco'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Elimina',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }
}
