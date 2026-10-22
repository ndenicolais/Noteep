// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../../core/routing/app_router.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:intl/intl.dart';
import '../../models/calendar_model.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/shared/app_dialogs.dart';
import 'calendar_event_tile.dart';

/// Shows the bottom sheet listing all events of a given [day], with a
/// shortcut to add a new event or open an existing one for editing.
void showDayEventsBottomSheet(
  BuildContext context,
  DateTime day,
  List<CalendarEventModel> events,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final dateStr = DateFormat('EEEE, d MMMM yyyy').format(day);

  showAppSheet(
    context,
    isScrollControlled: true,
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.85,
        builder: (_, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.sm,
                  AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final newEvent = CalendarEventModel(
                          startTime: day,
                          endTime: day.add(const Duration(hours: 1)),
                        );
                        AppNav.openEvent(context, newEvent);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(context.l10n.calendarAdd),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child:
                    events.isEmpty
                        ? Center(
                          child: Text(
                            context.l10n.calendarNoEventsDay,
                            style: TextStyle(color: colorScheme.outline),
                          ),
                        )
                        : ListView.builder(
                          controller: scrollController,
                          itemCount: events.length,
                          itemBuilder: (_, i) {
                            final event = events[i];
                            return CalendarEventListTile(
                              event: event,
                              onTap: () {
                                Navigator.pop(ctx);
                                AppNav.openEvent(context, event);
                              },
                            );
                          },
                        ),
              ),
            ],
          );
        },
      );
    },
  );
}
