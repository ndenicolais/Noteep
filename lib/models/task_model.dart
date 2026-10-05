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
  DateTime? reminder;
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
    this.reminder,
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
    DateTime? reminder,
    bool clearReminder = false,
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
      reminder: clearReminder ? null : (reminder ?? this.reminder),
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
    if (reminder != null) 'reminder': reminder!.toIso8601String(),
    'tags': tags,
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'] as String?,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    isCompleted: json['isCompleted'] as bool? ?? false,
    dueDate:
        json['dueDate'] != null
            ? DateTime.parse(json['dueDate'] as String)
            : null,
    isPinned: json['isPinned'] as bool? ?? false,
    isSpecial: json['isSpecial'] as bool? ?? false,
    isArchived: json['isArchived'] as bool? ?? false,
    listId: json['listId'] as String?,
    recurrence: recurrenceTypeFromString(
      json['recurrence'] as String? ?? 'none',
    ),
    reminder:
        json['reminder'] != null
            ? DateTime.parse(json['reminder'] as String)
            : null,
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
