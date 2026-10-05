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
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/task_model.dart';
import '../../models/subtask_model.dart';
import '../../models/task_change_history.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/tasks_undo_redo_provider.dart';
import '../../utils/notification_service.dart';
import '../../utils/recurrence.dart';
import '../../utils/dialogs/move_to_list_dialog.dart';
import '../../widgets/reminder_banner.dart';
import '../../widgets/shared/error_feedback.dart';
import 'task_editor_app_bar.dart';
import 'task_editor_bottom_bar.dart';
import 'task_info_section.dart';
import 'task_subtasks_section.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({super.key, required this.task});
  final TaskModel task;

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  late TaskModel _task;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _subtaskController;
  late FocusNode _titleFocusNode;
  late FocusNode _descriptionFocusNode;
  bool _isNew = false;
  bool _softDeleted = false;
  bool _isApplyingUndoRedo = false;
  String _lastTitle = '';
  String _lastDescription = '';

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    // Verifichiamo se il task esiste già nel provider
    _isNew = ref.read(tasksProvider).every((t) => t.id != _task.id);

    _titleController = TextEditingController(text: _task.title);
    _descriptionController = TextEditingController(text: _task.description);
    _subtaskController = TextEditingController();

    // Salva i valori iniziali
    _lastTitle = _titleController.text;
    _lastDescription = _descriptionController.text;

    // Crea FocusNode per tracciare quando finisci di digitare
    _titleFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();

    _titleFocusNode.addListener(_onTitleFocusChanged);
    _descriptionFocusNode.addListener(_onDescriptionFocusChanged);
    _titleController.addListener(_onTitleTextChanged);
    _descriptionController.addListener(_onDescriptionTextChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleTextChanged);
    _descriptionController.removeListener(_onDescriptionTextChanged);
    _titleFocusNode.removeListener(_onTitleFocusChanged);
    _descriptionFocusNode.removeListener(_onDescriptionFocusChanged);
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _onTitleFocusChanged() {
    if (!_titleFocusNode.hasFocus && !_isApplyingUndoRedo) {
      _commitTitleChange(_titleController.text);
    }
  }

  void _onDescriptionFocusChanged() {
    if (!_descriptionFocusNode.hasFocus && !_isApplyingUndoRedo) {
      _commitDescriptionChange(_descriptionController.text);
    }
  }

  void _onTitleTextChanged() {
    if (_isApplyingUndoRedo) return;
    final current = _titleController.text;
    if (_endsWithWordBoundary(current)) {
      _commitTitleChange(current);
    }
  }

  void _onDescriptionTextChanged() {
    if (_isApplyingUndoRedo) return;
    final current = _descriptionController.text;
    if (_endsWithWordBoundary(current)) {
      _commitDescriptionChange(current);
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
        .read(taskChangeHistoryProvider(_task.id).notifier)
        .addChange(TaskTitleChange(oldTitle: _lastTitle, newTitle: newTitle));
    _lastTitle = newTitle;
  }

  void _commitDescriptionChange(String newDescription) {
    if (newDescription == _lastDescription) return;
    ref
        .read(taskChangeHistoryProvider(_task.id).notifier)
        .addChange(
          TaskDescriptionChange(
            oldDescription: _lastDescription,
            newDescription: newDescription,
          ),
        );
    _lastDescription = newDescription;
  }

  bool _isEmpty() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    return title.isEmpty && description.isEmpty;
  }

  void _save() {
    if (_softDeleted) return;
    if (_isNew && _isEmpty()) return;

    final updated = _task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final Future<void> pending;
    if (_isNew) {
      pending = ref.read(tasksProvider.notifier).addTask(updated);
      _isNew = false;
    } else {
      pending = ref.read(tasksProvider.notifier).updateTask(updated);
    }
    notifyOnError(pending, context);
    setState(() => _task = updated);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Elimina task'),
            content: const Text('Vuoi spostare questo task nel cestino?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  notifyOnError(
                    ref.read(tasksProvider.notifier).deleteTask(_task.id),
                    context,
                  );
                  _softDeleted = true;
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Elimina',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showMoveToListDialog() {
    showMoveToListDialog(
      context: context,
      ref: ref,
      currentListId: _task.listId,
      onListSelected: (listId) {
        setState(() => _task = _task.copyWith(listId: listId));
      },
    );
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _task.dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _task = _task.copyWith(dueDate: date));
    }
  }

  void _showRecurrenceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ripetizione'),
            content: SingleChildScrollView(
              child: RadioGroup<RecurrenceType>(
                groupValue: _task.recurrence,
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _task = _task.copyWith(recurrence: v));
                    Navigator.pop(context);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final type in RecurrenceType.values)
                      RadioListTile<RecurrenceType>(
                        title: Text(recurrenceLabel(type)),
                        value: type,
                      ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isNotEmpty) {
      final newSubtask = SubtaskModel(title: text);
      setState(() {
        _task = _task.copyWith(subtasks: [..._task.subtasks, newSubtask]);
        _subtaskController.clear();
      });
    }
  }

  // ─── Share ────────────────────────────────────────────────────────────────

  void _shareTask() {
    final title = _task.title.trim();
    final desc = _task.description.trim();
    final subtaskLines = _task.subtasks
        .map((s) => '  ${s.isCompleted ? '☑' : '☐'} ${s.title}')
        .join('\n');

    final parts = <String>[
      if (title.isNotEmpty) title,
      if (desc.isNotEmpty) desc,
      if (subtaskLines.isNotEmpty) subtaskLines,
    ];

    final text = parts.join('\n\n');
    if (text.isEmpty) return;
    Share.share(text);
  }

  // ─── Reminder ─────────────────────────────────────────────────────────────

  Future<void> _setReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _task.reminder ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _task.reminder ?? now.add(const Duration(hours: 1)),
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

    final updated = _task.copyWith(reminder: scheduled);
    setState(() => _task = updated);
    _save();

    await NotificationService.instance.scheduleNotification(
      id: NotificationService.idForTask(_task.id),
      title: _task.title.isEmpty ? 'Promemoria task' : _task.title,
      body:
          _task.description.isEmpty
              ? 'Hai un promemoria per questo task'
              : _task.description.substring(
                0,
                _task.description.length > 80 ? 80 : _task.description.length,
              ),
      scheduledAt: scheduled,
    );

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
    await NotificationService.instance.cancelNotification(
      NotificationService.idForTask(_task.id),
    );
    final updated = _task.copyWith(clearReminder: true);
    setState(() => _task = updated);
    _save();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Promemoria rimosso')));
    }
  }

  void _toggleSubtask(int index, bool completed) {
    final updated = _task.subtasks[index].copyWith(isCompleted: completed);
    final newSubtasks = [..._task.subtasks];
    newSubtasks[index] = updated;
    setState(() => _task = _task.copyWith(subtasks: newSubtasks));
  }

  void _deleteSubtask(int index) {
    setState(() {
      _task = _task.copyWith(subtasks: _task.subtasks..removeAt(index));
    });
  }

  // ─── Undo / Redo ──────────────────────────────────────────────────────────

  void _performUndo() {
    _isApplyingUndoRedo = true;
    final undoneTask = TaskUndoRedoManager.performUndo(ref, _task.id, _task);
    if (undoneTask != null) {
      setState(() => _task = undoneTask);
      _titleController.text = undoneTask.title;
      _descriptionController.text = undoneTask.description;
      _lastTitle = undoneTask.title;
      _lastDescription = undoneTask.description;
    }
    _isApplyingUndoRedo = false;
  }

  void _performRedo() {
    _isApplyingUndoRedo = true;
    final redoneTask = TaskUndoRedoManager.performRedo(ref, _task.id, _task);
    if (redoneTask != null) {
      setState(() => _task = redoneTask);
      _titleController.text = redoneTask.title;
      _descriptionController.text = redoneTask.description;
      _lastTitle = redoneTask.title;
      _lastDescription = redoneTask.description;
    }
    _isApplyingUndoRedo = false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _save();
      },
      child: Scaffold(
        appBar: TaskEditorAppBar(
          task: _task,
          onUndo: () => setState(_performUndo),
          onRedo: () => setState(_performRedo),
          onTogglePin:
              () => setState(
                () => _task = _task.copyWith(isPinned: !_task.isPinned),
              ),
          onArchive: () {
            setState(
              () => _task = _task.copyWith(isArchived: !_task.isArchived),
            );
            _save();
            Navigator.pop(context);
          },
          onShare: _shareTask,
        ),
        body: Column(
          children: [
            if (_task.reminder != null)
              ReminderBanner(
                reminder: _task.reminder!,
                onTap: _setReminder,
                onRemove: _removeReminder,
              ),
            // Campo Titolo
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Titolo task',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(80),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            TaskInfoSection(
              task: _task,
              onClearDueDate:
                  () => setState(
                    () => _task = _task.copyWith(clearDueDate: true),
                  ),
            ),
            // Campo Descrizione
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _descriptionController,
                  focusNode: _descriptionFocusNode,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Descrizione...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            if (_task.subtasks.isNotEmpty)
              TaskSubtasksList(
                subtasks: _task.subtasks,
                onToggle: _toggleSubtask,
                onDelete: _deleteSubtask,
              ),
            TaskAddSubtaskField(
              controller: _subtaskController,
              onAdd: _addSubtask,
            ),
            // Footer con data ultima modifica
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Ultima modifica: ${DateFormat('dd MMM, HH:mm').format(_task.updatedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: TaskEditorBottomBar(
          hasReminder: _task.reminder != null,
          onDatePicker: _showDatePicker,
          onReminder: _setReminder,
          onRecurrence: _showRecurrenceDialog,
          onMoveToList: _showMoveToListDialog,
          onDelete: _confirmDelete,
        ),
      ),
    );
  }
}
