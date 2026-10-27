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
import 'package:intl/intl.dart';
import '../../models/calendar_model.dart';
import '../../providers/calendar_provider.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../core/routing/notification_target.dart';
import '../../utils/notification_service.dart';
import '../../widgets/shared/app_dialogs.dart';
import '../../widgets/reminder_banner.dart';
import '../../widgets/shared/error_feedback.dart';
import 'calendar_event_details_section.dart';
import 'calendar_event_editor_bars.dart';

class CalendarEventEditorScreen extends ConsumerStatefulWidget {
  const CalendarEventEditorScreen({super.key, required this.event});
  final CalendarEventModel event;

  @override
  ConsumerState<CalendarEventEditorScreen> createState() =>
      _CalendarEventEditorScreenState();
}

class _CalendarEventEditorScreenState
    extends ConsumerState<CalendarEventEditorScreen> {
  late CalendarEventModel _event;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isNew = false;
  bool _softDeleted = false;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    // Verifichiamo se l'evento esiste già nel provider
    _isNew = ref.read(calendarProvider).every((e) => e.id != _event.id);

    _titleController = TextEditingController(text: _event.title);
    _descriptionController = TextEditingController(text: _event.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isEmpty() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    return title.isEmpty && description.isEmpty;
  }

  void _save() {
    if (_softDeleted) return;
    if (_isNew && _isEmpty()) return;

    final updated = _event.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final Future<void> pending;
    if (_isNew) {
      pending = ref.read(calendarProvider.notifier).addEvent(updated);
      _isNew = false;
    } else {
      pending = ref.read(calendarProvider.notifier).updateEvent(updated);
    }
    notifyOnError(pending, context);
    setState(() => _event = updated);
  }

  void _openDateTimePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _event.startTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && mounted) {
      if (_event.isAllDay) {
        setState(
          () =>
              _event = _event.copyWith(
                startTime: selectedDate,
                endTime: selectedDate.add(const Duration(days: 1)),
              ),
        );
      } else {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_event.startTime),
        );

        if (selectedTime != null && mounted) {
          final newStart = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          final duration = _event.endTime.difference(_event.startTime);
          final newEnd = newStart.add(duration);

          setState(
            () =>
                _event = _event.copyWith(startTime: newStart, endTime: newEnd),
          );
        }
      }
    }
  }

  Future<void> _pickEndTime() async {
    final start = _event.startTime;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _event.hasEndTime
            ? _event.endTime
            : start.add(const Duration(hours: 1)),
      ),
    );
    if (selectedTime == null || !mounted) return;

    var end = DateTime(
      start.year,
      start.month,
      start.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    // An end earlier than the start means the event goes past midnight;
    // an end equal to the start means a single time (no end).
    if (end.isBefore(start)) end = end.add(const Duration(days: 1));
    setState(() => _event = _event.copyWith(endTime: end));
  }

  void _clearEndTime() {
    setState(() => _event = _event.copyWith(endTime: _event.startTime));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: context.l10n.calendarDeleteEvent,
      message: context.l10n.calendarDeleteEventConfirm,
      confirmLabel: context.l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    // A never-saved event is not in the provider: nothing to trash.
    if (!_isNew) {
      final notifier = ref.read(calendarProvider.notifier);
      final id = _event.id;
      notifyWithUndo(
        notifier.softDelete(id),
        context,
        message: context.l10n.calendarEventTrashed,
        onUndo: () => notifier.restoreFromTrash(id),
      );
    }
    _softDeleted = true;
    Navigator.pop(context);
  }

  // ─── Reminder ─────────────────────────────────────────────────────────────

  Future<void> _setReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _event.reminder ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _event.reminder ?? now.add(const Duration(hours: 1)),
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

    final updated = _event.copyWith(reminder: scheduled);
    setState(() => _event = updated);
    _save();

    final l10n = context.l10n;
    await NotificationService.instance.scheduleNotification(
      id: NotificationService.idForEvent(_event.id),
      title:
          _event.title.isEmpty
              ? l10n.calendarReminderNotificationTitle
              : _event.title,
      body:
          _event.description.isEmpty
              ? l10n.calendarReminderNotificationBody
              : _event.description.substring(
                0,
                _event.description.length > 80 ? 80 : _event.description.length,
              ),
      scheduledAt: scheduled,
      target: NotificationTarget.event(_event.id),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.commonReminderScheduled(
              DateFormat('dd MMM, HH:mm').format(scheduled),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _removeReminder() async {
    await NotificationService.instance.cancelNotification(
      NotificationService.idForEvent(_event.id),
    );
    final updated = _event.copyWith(clearReminder: true);
    setState(() => _event = updated);
    _save();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.commonReminderRemoved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _save();
      },
      child: Scaffold(
        appBar: CalendarEventEditorAppBar(
          isPinned: _event.isPinned,
          isArchived: _event.isArchived,
          onTogglePin:
              () => setState(
                () => _event = _event.copyWith(isPinned: !_event.isPinned),
              ),
          onToggleArchive: () {
            setState(
              () => _event = _event.copyWith(isArchived: !_event.isArchived),
            );
            _save();
            Navigator.pop(context);
          },
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (_event.reminder != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: ReminderBanner(
                    reminder: _event.reminder!,
                    onTap: _setReminder,
                    onRemove: _removeReminder,
                  ),
                ),
              ),
            // Titolo (Obbligatorio)
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                fontSize: AppFontSizes.headline,
                fontWeight: FontWeight.bold,
              ),
              maxLines: null,
              decoration: InputDecoration(
                hintText: context.l10n.calendarTitleHint,
                hintStyle: TextStyle(
                  fontSize: AppFontSizes.headline,
                  color: colorScheme.onSurface.withAlpha(100),
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CalendarEventDetailsSection(
              event: _event,
              onPickDateTime: _openDateTimePicker,
              onPickEndTime: _pickEndTime,
              onClearEndTime: _clearEndTime,
              onChanged: (e) => setState(() => _event = e),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Descrizione (Opzionale)
            TextField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: AppFontSizes.lg),
              maxLines: null,
              minLines: 4,
              decoration: InputDecoration(
                hintText: context.l10n.calendarDescriptionHint,
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withAlpha(100),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.commonLastModified(
                DateFormat('dd MMM, HH:mm').format(_event.updatedAt),
              ),
              style: TextStyle(
                fontSize: AppFontSizes.sm,
                color: colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CalendarEventEditorBottomBar(
          hasReminder: _event.reminder != null,
          onDelete: _confirmDelete,
          onReminder: _setReminder,
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
