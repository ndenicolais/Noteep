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
import 'package:intl/intl.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/shared/app_dialogs.dart';

/// What the new-task sheet collected. [due] carries a time only when one
/// was picked: the task notifies at that time.
typedef NewTaskDraft =
    ({String title, String description, DateTime? due, bool starred});

/// Google Tasks-like quick add: title, optional details, due date (then an
/// optional time, first offered at [defaultTime]) and star. Resolves to
/// `null` when dismissed or left without a title.
Future<NewTaskDraft?> showNewTaskSheet(
  BuildContext context, {
  required TimeOfDay defaultTime,
  bool starred = false,
}) {
  return showAppSheet<NewTaskDraft>(
    context,
    isScrollControlled: true,
    builder: (_) => _NewTaskSheet(defaultTime: defaultTime, starred: starred),
  );
}

class _NewTaskSheet extends StatefulWidget {
  const _NewTaskSheet({required this.defaultTime, required this.starred});

  final TimeOfDay defaultTime;
  final bool starred;

  @override
  State<_NewTaskSheet> createState() => _NewTaskSheetState();
}

class _NewTaskSheetState extends State<_NewTaskSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  bool _showDescription = false;
  DateTime? _due;
  bool _hasTime = false;
  late bool _starred = widget.starred;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  /// Due date, then its time: cancelling the time keeps a day-only date.
  Future<void> _pickDue() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime:
          _due != null && _hasTime
              ? TimeOfDay.fromDateTime(_due!)
              : widget.defaultTime,
    );
    if (!mounted) return;
    setState(() {
      _hasTime = time != null;
      _due =
          time == null
              ? date
              : DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
    });
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    Navigator.pop<NewTaskDraft>(context, (
      title: title,
      description: _description.text.trim(),
      due: _due,
      starred: _starred,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l10n.tasksNewTaskHint,
              border: InputBorder.none,
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_showDescription)
            TextField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              decoration: InputDecoration(
                hintText: l10n.taskEditorDescriptionHint,
                border: InputBorder.none,
              ),
            ),
          if (_due != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: InputChip(
                avatar: Icon(
                  _hasTime ? Icons.alarm : Icons.calendar_today_outlined,
                  size: 18,
                ),
                label: Text(
                  DateFormat(
                    _hasTime ? 'EEE d MMM, HH:mm' : 'EEE d MMM',
                  ).format(_due!),
                ),
                onPressed: _pickDue,
                onDeleted:
                    () => setState(() {
                      _due = null;
                      _hasTime = false;
                    }),
                deleteButtonTooltipMessage: l10n.tasksRemoveDueDate,
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notes),
                tooltip: l10n.tasksAddDetails,
                color: _showDescription ? cs.primary : null,
                onPressed:
                    () => setState(() => _showDescription = !_showDescription),
              ),
              IconButton(
                icon: const Icon(Icons.event_available_outlined),
                tooltip: l10n.taskEditorDueDate,
                color: _due != null ? cs.primary : null,
                onPressed: _pickDue,
              ),
              IconButton(
                icon: Icon(_starred ? Icons.star : Icons.star_border),
                color: _starred ? Colors.amber : null,
                tooltip: _starred ? l10n.tasksRemoveStar : l10n.tasksAddStar,
                onPressed: () => setState(() => _starred = !_starred),
              ),
              const Spacer(),
              TextButton(
                onPressed: _title.text.trim().isEmpty ? null : _submit,
                child: Text(l10n.commonSave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
