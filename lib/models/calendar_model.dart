// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/painting.dart';
import 'package:uuid/uuid.dart';
import '../utils/recurrence.dart';
import 'task_model.dart';

class CalendarEventModel {
  final String id;
  String title;
  String description;
  // Free-text place (address or name), opened in the maps app from the
  // event view. Empty when not set.
  String location;
  // Card fill chosen by the user; null keeps the color of the event kind
  // (see `calendarItemStyle`). A note swatch is shown as its counterpart
  // in the other theme.
  Color? color;
  DateTime startTime;
  // Equal to [startTime] for a timed event with a single time (no end).
  DateTime endTime;
  bool isAllDay;
  bool isBirthday;
  bool isNameDay;
  bool isPinned;
  bool isArchived;
  RecurrenceType recurrence;
  // If set, the recurrence stops producing occurrences after this date
  // (inclusive) — e.g. an imported ICS RRULE with UNTIL= or COUNT=.
  DateTime? recurrenceEndDate;
  // Alerts of all-day events, repeated on every occurrence: on the day
  // itself and/or the day before, at the Settings time (09:00 by default).
  // Timed events always alert at their start time and ignore these flags.
  // See `utils/event_alerts.dart`.
  bool alertSameDay;
  bool alertDayBefore;
  List<String> tags;
  final DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  CalendarEventModel({
    String? id,
    this.title = '',
    this.description = '',
    this.location = '',
    this.color,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.isBirthday = false,
    this.isNameDay = false,
    this.isPinned = false,
    this.isArchived = false,
    this.recurrence = RecurrenceType.none,
    this.recurrenceEndDate,
    this.alertSameDay = false,
    this.alertDayBefore = false,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : id = id ?? const Uuid().v4(),
       tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  bool get hasEndTime => !isAllDay && endTime.isAfter(startTime);

  /// Whether an occurrence alerts on its own day: always for a timed event
  /// (at its start time), only when chosen for an all-day one.
  bool get notifiesSameDay => !isAllDay || alertSameDay;

  /// Whether an occurrence alerts the day before (all-day events only).
  bool get notifiesDayBefore => isAllDay && alertDayBefore;

  bool get hasAlerts => notifiesSameDay || notifiesDayBefore;

  /// Whether an occurrence of this event (recurrence and its end included)
  /// falls on [day].
  bool occursOn(DateTime day) {
    final s = startTime;
    final startDay = DateTime(s.year, s.month, s.day);
    final targetDay = DateTime(day.year, day.month, day.day);
    if (startDay.isAfter(targetDay)) return false;

    final end = recurrenceEndDate;
    if (end != null) {
      final endDay = DateTime(end.year, end.month, end.day);
      if (targetDay.isAfter(endDay)) return false;
    }

    switch (recurrence) {
      case RecurrenceType.none:
        return s.year == day.year && s.month == day.month && s.day == day.day;
      case RecurrenceType.daily:
        return true;
      case RecurrenceType.weekly:
        return s.weekday == day.weekday;
      case RecurrenceType.monthly:
        return s.day == day.day;
      case RecurrenceType.yearly:
        return s.month == day.month && s.day == day.day;
    }
  }

  CalendarEventModel copyWith({
    String? title,
    String? description,
    String? location,
    Color? color,
    bool clearColor = false,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    bool? isBirthday,
    bool? isNameDay,
    bool? isPinned,
    bool? isArchived,
    RecurrenceType? recurrence,
    DateTime? recurrenceEndDate,
    bool clearRecurrenceEndDate = false,
    bool? alertSameDay,
    bool? alertDayBefore,
    List<String>? tags,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return CalendarEventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      color: clearColor ? null : (color ?? this.color),
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      isBirthday: isBirthday ?? this.isBirthday,
      isNameDay: isNameDay ?? this.isNameDay,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      recurrence: recurrence ?? this.recurrence,
      recurrenceEndDate:
          clearRecurrenceEndDate
              ? null
              : (recurrenceEndDate ?? this.recurrenceEndDate),
      alertSameDay: alertSameDay ?? this.alertSameDay,
      alertDayBefore: alertDayBefore ?? this.alertDayBefore,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    if (location.isNotEmpty) 'location': location,
    if (color != null) 'color': color!.toARGB32(),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'isAllDay': isAllDay,
    'isBirthday': isBirthday,
    'isNameDay': isNameDay,
    'isPinned': isPinned,
    'isArchived': isArchived,
    'recurrence': recurrence.toShortString(),
    if (recurrenceEndDate != null)
      'recurrenceEndDate': recurrenceEndDate!.toIso8601String(),
    'alertSameDay': alertSameDay,
    'alertDayBefore': alertDayBefore,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) =>
      CalendarEventModel(
        id: json['id'] as String?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        location: json['location'] as String? ?? '',
        color: json['color'] != null ? Color(json['color'] as int) : null,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        isAllDay: json['isAllDay'] as bool? ?? false,
        isBirthday: json['isBirthday'] as bool? ?? false,
        isNameDay: json['isNameDay'] as bool? ?? false,
        isPinned: json['isPinned'] as bool? ?? false,
        isArchived: json['isArchived'] as bool? ?? false,
        recurrence: recurrenceTypeFromString(
          json['recurrence'] as String? ?? 'none',
        ),
        recurrenceEndDate:
            json['recurrenceEndDate'] != null
                ? DateTime.parse(json['recurrenceEndDate'] as String)
                : null,
        alertSameDay: json['alertSameDay'] as bool? ?? false,
        alertDayBefore: json['alertDayBefore'] as bool? ?? false,
        tags:
            (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        deletedAt:
            json['deletedAt'] != null
                ? DateTime.parse(json['deletedAt'] as String)
                : null,
      );
}

/// Read-only calendar entry built from a [TaskModel] with a due date, so
/// tasks can be listed in the calendar views next to events. It is placed
/// at the due time when the due date has one, else as an all-day entry on
/// the due date. Never persisted: tap opens the task view (see
/// `AppNav.openCalendarItem`).
class TaskCalendarEvent extends CalendarEventModel {
  TaskCalendarEvent(this.task)
    : super(
        id: 'task_${task.id}',
        title: task.title,
        description: task.description,
        startTime: task.dueDate!,
        endTime: task.dueDate!,
        isAllDay: !task.hasDueTime,
        recurrence: task.recurrence,
        tags: task.tags,
        createdAt: task.createdAt,
        updatedAt: task.updatedAt,
      );

  final TaskModel task;

  /// Whether [task] can be shown in the calendar at all.
  static bool isShown(TaskModel task) => task.dueDate != null;
}
