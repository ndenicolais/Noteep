// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:uuid/uuid.dart';
import '../utils/recurrence.dart';
import 'subtask_model.dart';

class TaskModel {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime? dueDate;
  bool isPinned;
  bool isSpecial;
  bool isArchived;
  String? listId;
  RecurrenceType recurrence;
  List<String> tags;
  List<SubtaskModel> subtasks;
  final DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  TaskModel({
    String? id,
    this.title = '',
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
    this.isPinned = false,
    this.isSpecial = false,
    this.isArchived = false,
    this.listId,
    this.recurrence = RecurrenceType.none,
    List<String>? tags,
    List<SubtaskModel>? subtasks,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : id = id ?? const Uuid().v4(),
       tags = tags ?? [],
       subtasks = subtasks ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Whether [dueDate] carries a time of day; the date picker stores
  /// midnight when no time is picked. A due time is also when the task
  /// notifies (see `NotificationService.scheduleTaskReminder`).
  bool get hasDueTime =>
      dueDate != null && (dueDate!.hour != 0 || dueDate!.minute != 0);

  /// Whether this task repeats on a schedule (a recurrence needs a due date
  /// to step from).
  bool get isRecurring => recurrence != RecurrenceType.none && dueDate != null;

  /// This task moved on to its next occurrence: the due date steps forward
  /// by one recurrence and the task is open again.
  TaskModel nextOccurrence() => copyWith(
    dueDate: nextRecurrence(dueDate!, recurrence),
    isCompleted: false,
    updatedAt: DateTime.now(),
  );

  TaskModel copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? isPinned,
    bool? isSpecial,
    bool? isArchived,
    String? listId,
    bool clearListId = false,
    RecurrenceType? recurrence,
    List<String>? tags,
    List<SubtaskModel>? subtasks,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      isPinned: isPinned ?? this.isPinned,
      isSpecial: isSpecial ?? this.isSpecial,
      isArchived: isArchived ?? this.isArchived,
      listId: clearListId ? null : (listId ?? this.listId),
      recurrence: recurrence ?? this.recurrence,
      tags: tags ?? this.tags,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    'isPinned': isPinned,
    'isSpecial': isSpecial,
    'isArchived': isArchived,
    if (listId != null) 'listId': listId,
    'recurrence': recurrence.toShortString(),
    'tags': tags,
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };

  /// The due date of [json]. Older data had a separate `reminder`: when
  /// there is no due date, or a date-only one on the reminder's day, the
  /// reminder becomes the due date, so the task keeps its day and time.
  static DateTime? _dueDateFromJson(Map<String, dynamic> json) {
    final due =
        json['dueDate'] != null
            ? DateTime.parse(json['dueDate'] as String)
            : null;
    final reminder =
        json['reminder'] != null
            ? DateTime.parse(json['reminder'] as String)
            : null;
    if (reminder == null) return due;
    if (due == null) return reminder;
    final dateOnly = due.hour == 0 && due.minute == 0;
    final sameDay =
        due.year == reminder.year &&
        due.month == reminder.month &&
        due.day == reminder.day;
    return dateOnly && sameDay ? reminder : due;
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'] as String?,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    isCompleted: json['isCompleted'] as bool? ?? false,
    dueDate: _dueDateFromJson(json),
    isPinned: json['isPinned'] as bool? ?? false,
    isSpecial: json['isSpecial'] as bool? ?? false,
    isArchived: json['isArchived'] as bool? ?? false,
    listId: json['listId'] as String?,
    recurrence: recurrenceTypeFromString(
      json['recurrence'] as String? ?? 'none',
    ),
    tags:
        (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        [],
    subtasks:
        (json['subtasks'] as List<dynamic>?)
            ?.map((e) => SubtaskModel.fromJson(e as Map<String, dynamic>))
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
