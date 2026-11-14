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

/// Day picked in [showDateTimePickerDialog] and its optional time.
typedef DateTimeSelection = ({DateTime date, TimeOfDay? time});

extension DateTimeSelectionX on DateTimeSelection {
  /// [date] at [time], or the bare day when there is no time.
  DateTime get combined {
    final t = time;
    return t == null
        ? DateTime(date.year, date.month, date.day)
        : DateTime(date.year, date.month, date.day, t.hour, t.minute);
  }
}

/// Single dialog with the month grid and, below it, a time chip, like
/// Google Tasks: changing only the day or only the time takes one tap
/// plus "Fine" instead of going through two pickers in a row.
///
/// [initialTime] null means no time yet; [defaultTime] is the time first
/// offered when one is added for the selected day. [timeRequired] hides
/// the chip's remove button (a reminder always has a time); [showTime]
/// false shows the calendar only (all-day events). Resolves to `null`
/// when cancelled or dismissed.
Future<DateTimeSelection?> showDateTimePickerDialog(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  TimeOfDay? initialTime,
  required TimeOfDay Function(DateTime date) defaultTime,
  bool timeRequired = false,
  bool showTime = true,
}) {
  return showDialog<DateTimeSelection>(
    context: context,
    builder:
        (_) => _DateTimePickerDialog(
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          initialTime: initialTime,
          defaultTime: defaultTime,
          timeRequired: timeRequired,
          showTime: showTime,
        ),
  );
}

class _DateTimePickerDialog extends StatefulWidget {
  const _DateTimePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.initialTime,
    required this.defaultTime,
    required this.timeRequired,
    required this.showTime,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final TimeOfDay? initialTime;
  final TimeOfDay Function(DateTime date) defaultTime;
  final bool timeRequired;
  final bool showTime;

  @override
  State<_DateTimePickerDialog> createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<_DateTimePickerDialog> {
  late DateTime _first;
  late DateTime _last;
  late DateTime _date;
  TimeOfDay? _time;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _first = _day(widget.firstDate);
    _last = _day(widget.lastDate);
    final initial = _day(widget.initialDate);
    // CalendarDatePicker asserts the initial day is within the range.
    _date =
        initial.isBefore(_first)
            ? _first
            : initial.isAfter(_last)
            ? _last
            : initial;
    _time =
        widget.initialTime ??
        (widget.timeRequired ? widget.defaultTime(_date) : null);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? widget.defaultTime(_date),
    );
    if (picked != null && mounted) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CalendarDatePicker(
                initialDate: _date,
                firstDate: _first,
                lastDate: _last,
                onDateChanged: (d) => setState(() => _date = _day(d)),
              ),
              if (widget.showTime) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 16),
                      if (_time == null)
                        TextButton(
                          onPressed: _pickTime,
                          child: Text(l10n.dateTimePickerAddTime),
                        )
                      else
                        InputChip(
                          label: Text(_time!.format(context)),
                          onPressed: _pickTime,
                          onDeleted:
                              widget.timeRequired
                                  ? null
                                  : () => setState(() => _time = null),
                          deleteButtonTooltipMessage:
                              l10n.dateTimePickerRemoveTime,
                        ),
                    ],
                  ),
                ),
              ],
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.commonCancel),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed:
                          () => Navigator.pop<DateTimeSelection>(context, (
                            date: _date,
                            time: widget.showTime ? _time : null,
                          )),
                      child: Text(l10n.commonDone),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
