// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:uuid/uuid.dart';
import '../utils/recurrence.dart';

class CalendarEventModel {
  final String id;
  String title;
  String description;
  DateTime startTime;
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
  DateTime? reminder;
  List<String> tags;
  final DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  CalendarEventModel({
    String? id,
    this.title = '',
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.isBirthday = false,
    this.isNameDay = false,
    this.isPinned = false,
    this.isArchived = false,
    this.recurrence = RecurrenceType.none,
    this.recurrenceEndDate,
    this.reminder,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : id = id ?? const Uuid().v4(),
       tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  CalendarEventModel copyWith({
    String? title,
    String? description,
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
    DateTime? reminder,
    bool clearReminder = false,
    List<String>? tags,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return CalendarEventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
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
      reminder: clearReminder ? null : (reminder ?? this.reminder),
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
    if (reminder != null) 'reminder': reminder!.toIso8601String(),
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
        reminder:
            json['reminder'] != null
                ? DateTime.parse(json['reminder'] as String)
                : null,
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
