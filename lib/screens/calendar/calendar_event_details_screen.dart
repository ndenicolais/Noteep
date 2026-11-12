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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/routing/app_router.dart';
import '../../l10n/l10n.dart';
import '../../models/calendar_model.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/settings/ui_provider.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
import '../../utils/event_alerts.dart';
import '../../utils/notification_service.dart';
import '../../utils/recurrence.dart';
import '../../widgets/shared/app_dialogs.dart';
import '../../widgets/shared/detail_row.dart';
import '../../widgets/shared/error_feedback.dart';
import 'calendar_event_style.dart';
import 'calendar_event_tile.dart';

/// Read-only view of a saved event, opened by tapping it (like Google
/// Calendar): the pencil opens [CalendarEventEditorScreen]. Follows the
/// event in [calendarProvider], so edits show up on return and the screen
/// closes once the event is trashed.
class CalendarEventDetailsScreen extends ConsumerStatefulWidget {
  const CalendarEventDetailsScreen({super.key, required this.event});
  final CalendarEventModel event;

  @override
  ConsumerState<CalendarEventDetailsScreen> createState() =>
      _CalendarEventDetailsScreenState();
}

class _CalendarEventDetailsScreenState
    extends ConsumerState<CalendarEventDetailsScreen> {
  bool _closing = false;

  CalendarEventModel _current(List<CalendarEventModel> events) {
    for (final e in events) {
      if (e.id == widget.event.id) return e;
    }
    return widget.event;
  }

  void _close() {
    if (_closing) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.maybePop(context);
    });
  }

  Future<void> _delete(CalendarEventModel event) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: context.l10n.calendarDeleteEvent,
      message: context.l10n.calendarDeleteEventConfirm,
      confirmLabel: context.l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    final notifier = ref.read(calendarProvider.notifier);
    NotificationService.instance.cancelEventAlerts(event.id).ignore();
    notifyWithUndo(
      notifier.softDelete(event.id),
      context,
      message: context.l10n.calendarEventTrashed,
      onUndo: () => notifier.restoreFromTrash(event.id),
    );
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final event = _current(ref.watch(calendarProvider));
    if (event.deletedAt != null) _close();

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final style = calendarItemStyle(event, cs);
    final alertAt = DateFormat('HH:mm').format(
      occurrenceTime(
        event,
        event.startTime,
        allDayMinutes: ref.watch(defaultAlertTimeProvider),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendarEventTitle),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.commonEdit,
            onPressed: () => AppNav.openEvent(context, event),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.calendarDeleteEvent,
            onPressed: () => _delete(event),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 7, right: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: style.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Text(
                  event.title.isEmpty ? l10n.commonUntitled : event.title,
                  style: TextStyle(
                    fontSize: AppFontSizes.headline,
                    fontWeight: FontWeight.bold,
                    color: event.title.isEmpty ? cs.onSurfaceVariant : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (event.isBirthday || event.isNameDay)
            DetailRow(
              icon: style.icon ?? Icons.event,
              iconColor: style.accent,
              child: Text(
                event.isBirthday ? l10n.calendarBirthday : l10n.calendarNameDay,
              ),
            ),
          DetailRow(
            icon: Icons.calendar_today_outlined,
            subtitle: formatEventTimeRange(l10n, event),
            child: Text(DateFormat('EEEE d MMMM yyyy').format(event.startTime)),
          ),
          if (event.recurrence != RecurrenceType.none)
            DetailRow(
              icon: Icons.repeat,
              child: Text(event.recurrence.label(l10n)),
            ),
          if (event.notifiesDayBefore)
            DetailRow(
              icon: Icons.notifications_outlined,
              subtitle: l10n.calendarAlertAt(alertAt),
              child: Text(l10n.calendarAlertDayBefore),
            ),
          // Always for a timed event: it alerts at its start.
          if (event.notifiesSameDay)
            DetailRow(
              icon: Icons.notifications_active_outlined,
              subtitle: l10n.calendarAlertAt(alertAt),
              child: Text(l10n.calendarAlertSameDay),
            ),
          if (event.description.isNotEmpty)
            DetailRow(
              icon: Icons.notes,
              child: SelectableText(event.description),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.commonLastModified(
              DateFormat('dd MMM, HH:mm').format(event.updatedAt),
            ),
            style: TextStyle(
              fontSize: AppFontSizes.sm,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
