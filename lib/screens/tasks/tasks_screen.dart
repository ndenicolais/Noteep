// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_list_model.dart';
import '../../models/task_model.dart';
import '../../providers/settings/ui_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../widgets/nav_scaffold.dart';
import '../../widgets/shared/app_dialogs.dart';
import '../../widgets/shared/error_feedback.dart';
import '../../widgets/shared/search_field.dart';
import '../../widgets/sort_sheet.dart';
import 'task_list_view.dart';

/// Tasks section: fixed "Tutte"/"Speciali" tabs plus one per task list.
/// Tab index 0 = all, 1 = special, 2+ = `taskLists[index - 2]`.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// The task list shown by the current tab, if it is a list tab.
  TaskListModel? _currentList(TabController tabs) {
    final lists = ref.read(taskListsProvider);
    final i = tabs.index - 2;
    return i >= 0 && i < lists.length ? lists[i] : null;
  }

  Future<void> _addTask(BuildContext tabContext) async {
    final tabs = DefaultTabController.of(tabContext);
    final title = await showAppTextInputDialog(
      tabContext,
      title: tabContext.l10n.tasksNewTask,
      hintText: tabContext.l10n.tasksNewTaskHint,
      confirmLabel: tabContext.l10n.tasksAdd,
      textCapitalization: TextCapitalization.sentences,
    );
    if (title == null || !tabContext.mounted) return;
    // New tasks land in the tab they were created from.
    final task = TaskModel(
      title: title,
      listId: _currentList(tabs)?.id,
      isSpecial: tabs.index == 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    notifyOnError(ref.read(tasksProvider.notifier).addTask(task), tabContext);
  }

  Future<void> _createList() async {
    final name = await showAppTextInputDialog(
      context,
      title: context.l10n.tasksNewList,
      hintText: context.l10n.tasksListNameHint,
      confirmLabel: context.l10n.tasksCreate,
      textCapitalization: TextCapitalization.sentences,
    );
    if (name == null) return;
    ref.read(taskListsProvider.notifier).addList(TaskListModel(name: name));
  }

  Future<void> _deleteCurrentList(BuildContext tabContext) async {
    final tabs = DefaultTabController.of(tabContext);
    final list = _currentList(tabs);
    if (list == null) return;
    final confirmed = await showAppConfirmDialog(
      tabContext,
      title: tabContext.l10n.tasksDeleteList,
      message: tabContext.l10n.tasksDeleteListConfirm(list.name),
      confirmLabel: tabContext.l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    // Jump away from this tab first: deleting the list shrinks the tab
    // count, and leaving the controller on an index that no longer exists
    // throws a RangeError.
    tabs.animateTo(0);
    ref.read(taskListsProvider.notifier).deleteList(list.id);
  }

  void _showSortSheet(BuildContext context) {
    final current = ref.read(taskSortOrderProvider);
    showAppSheet(
      context,
      builder:
          (_) => SortSheet(
            current: current,
            onChanged: (s) {
              ref.read(taskSortOrderProvider.notifier).set(s);
              Navigator.pop(context);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskLists = ref.watch(taskListsProvider);

    return DefaultTabController(
      length: 2 + taskLists.length,
      // Builder: the actions need a context below DefaultTabController.
      child: Builder(
        builder: (tabContext) {
          return NavScaffold(
            section: DrawerSection.tasks,
            titleWidget: SearchField(
              controller: _searchController,
              provider: taskSearchQueryProvider,
              hintText: context.l10n.tasksSearchHint,
            ),
            appBarActions: [
              ListenableBuilder(
                listenable: DefaultTabController.of(tabContext),
                builder:
                    (context, _) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (DefaultTabController.of(context).index > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteCurrentList(tabContext),
                            tooltip: context.l10n.tasksDeleteList,
                          ),
                        IconButton(
                          icon: const Icon(Icons.sort),
                          onPressed: () => _showSortSheet(tabContext),
                          tooltip: context.l10n.tasksSortTooltip,
                        ),
                        IconButton(
                          icon: const Icon(Icons.playlist_add),
                          onPressed: _createList,
                          tooltip: context.l10n.tasksNewList,
                        ),
                      ],
                    ),
              ),
            ],
            floatingActionButton: FloatingActionButton(
              onPressed: () => _addTask(tabContext),
              tooltip: context.l10n.tasksNewTask,
              child: const Icon(Icons.add),
            ),
            body: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: context.l10n.tasksTabAll),
                    Tab(text: context.l10n.tasksTabStarred),
                    for (final l in taskLists) Tab(text: l.name),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      TaskListView(source: filteredTasksProvider),
                      TaskListView(source: specialTasksProvider),
                      for (final l in taskLists)
                        TaskListView(source: taskListTasksProvider(l.id)),
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
