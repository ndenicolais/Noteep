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
import '../../models/calendar_model.dart';
import '../../providers/calendar_provider.dart';
import '../../utils/notification_service.dart';
import '../../utils/recurrence.dart';
import '../../widgets/shared/error_feedback.dart';

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

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Elimina evento'),
            content: const Text('Vuoi spostare questo evento nel cestino?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  // A never-saved event is not in the provider: nothing to trash.
                  if (!_isNew) {
                    final notifier = ref.read(calendarProvider.notifier);
                    final id = _event.id;
                    notifyWithUndo(
                      notifier.softDelete(id),
                      context,
                      message: 'Evento spostato nel cestino',
                      onUndo: () => notifier.restoreFromTrash(id),
                    );
                  }
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

    await NotificationService.instance.scheduleNotification(
      id: NotificationService.idForEvent(_event.id),
      title: _event.title.isEmpty ? 'Promemoria evento' : _event.title,
      body:
          _event.description.isEmpty
              ? 'Hai un promemoria per questo evento'
              : _event.description.substring(
                0,
                _event.description.length > 80 ? 80 : _event.description.length,
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
      NotificationService.idForEvent(_event.id),
    );
    final updated = _event.copyWith(clearReminder: true);
    setState(() => _event = updated);
    _save();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Promemoria rimosso')));
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
        appBar: AppBar(
          title: const Text('Evento'),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                _event.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              onPressed:
                  () => setState(
                    () => _event = _event.copyWith(isPinned: !_event.isPinned),
                  ),
              tooltip: _event.isPinned ? 'Sposta in alto' : 'Fissa in alto',
            ),
            IconButton(
              icon: Icon(
                _event.isArchived ? Icons.unarchive : Icons.archive_outlined,
              ),
              tooltip: _event.isArchived ? 'Ripristina' : 'Archivia',
              onPressed: () {
                setState(
                  () =>
                      _event = _event.copyWith(isArchived: !_event.isArchived),
                );
                _save();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Reminder banner
            if (_event.reminder != null)
              GestureDetector(
                onTap: _setReminder,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withAlpha(180),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.alarm,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(_event.reminder!),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _removeReminder,
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Titolo (Obbligatorio)
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Titolo',
                hintStyle: TextStyle(
                  fontSize: 24,
                  color: colorScheme.onSurface.withAlpha(100),
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),

            // Data (Opzionale)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(
                DateFormat(
                  'EEEE, dd MMMM yyyy',
                  'it_IT',
                ).format(_event.startTime),
              ),
              subtitle:
                  _event.isAllDay
                      ? const Text('Tutto il giorno')
                      : Text(
                        '${DateFormat('HH:mm').format(_event.startTime)} - '
                        '${DateFormat('HH:mm').format(_event.endTime)}',
                      ),
              onTap: _openDateTimePicker,
            ),
            const SizedBox(height: 8),

            // Toggle All Day
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tutto il giorno'),
              value: _event.isAllDay,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _event = _event.copyWith(isAllDay: value));
                }
              },
            ),
            const SizedBox(height: 8),

            // Toggle Birthday
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.cake_outlined),
              title: const Text('Compleanno'),
              value: _event.isBirthday,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _event = _event.copyWith(isBirthday: value));
                }
              },
            ),

            // Toggle Name Day
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.auto_awesome_outlined),
              title: const Text('Onomastico'),
              value: _event.isNameDay,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _event = _event.copyWith(isNameDay: value));
                }
              },
            ),
            const SizedBox(height: 16),

            // Ricorrenza
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.repeat_outlined),
              title: const Text('Ricorrenza'),
              subtitle: Text(_event.recurrence.label),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder:
                      (ctx) => ListView(
                        shrinkWrap: true,
                        children:
                            RecurrenceType.values
                                .map(
                                  (type) => ListTile(
                                    title: Text(type.label),
                                    selected: _event.recurrence == type,
                                    onTap: () {
                                      setState(
                                        () =>
                                            _event = _event.copyWith(
                                              recurrence: type,
                                            ),
                                      );
                                      Navigator.pop(ctx);
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Descrizione (Opzionale)
            TextField(
              controller: _descriptionController,
              style: const TextStyle(fontSize: 16),
              maxLines: null,
              minLines: 4,
              decoration: InputDecoration(
                hintText: 'Descrizione',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withAlpha(100),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data ultima modifica
            Text(
              'Ultima modifica: ${DateFormat('dd MMM, HH:mm').format(_event.updatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _confirmDelete,
                tooltip: 'Elimina evento',
              ),
              IconButton(
                icon: Icon(
                  _event.reminder != null
                      ? Icons.alarm
                      : Icons.alarm_add_outlined,
                  color:
                      _event.reminder != null
                          ? Theme.of(context).colorScheme.primary
                          : null,
                ),
                onPressed: _setReminder,
                tooltip: 'Promemoria',
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Chiudi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
