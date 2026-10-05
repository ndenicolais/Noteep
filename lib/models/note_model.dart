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
import 'package:uuid/uuid.dart';
import 'audio_note.dart';

enum NoteType { note, checklist }

class ChecklistItem {
  final String id;
  String text;
  bool isChecked;

  ChecklistItem({String? id, required this.text, this.isChecked = false})
    : id = id ?? const Uuid().v4();

  ChecklistItem copyWith({String? text, bool? isChecked}) {
    return ChecklistItem(
      id: id,
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isChecked': isChecked,
  };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
    id: json['id'] as String?,
    text: json['text'] as String,
    isChecked: json['isChecked'] as bool? ?? false,
  );
}

class NoteStyle {
  final String fontFamily;
  final double fontSize;
  final Color? backgroundColor;
  final Color? fontColor;
  final bool isBold;
  final bool isItalic;
  final bool isStrikethrough;
  final Color? titleFontColor;
  final String? titleFontFamily;
  final double? titleFontSize;
  final bool? titleIsBold;
  final bool? titleIsItalic;

  const NoteStyle({
    this.fontFamily = 'Exo 2',
    this.fontSize = 16.0,
    this.backgroundColor,
    this.fontColor,
    this.isBold = false,
    this.isItalic = false,
    this.isStrikethrough = false,
    this.titleFontColor,
    this.titleFontFamily,
    this.titleFontSize,
    this.titleIsBold,
    this.titleIsItalic,
  });

  NoteStyle copyWith({
    String? fontFamily,
    double? fontSize,
    Color? backgroundColor,
    Color? fontColor,
    bool? isBold,
    bool? isItalic,
    bool? isStrikethrough,
    Color? titleFontColor,
    String? titleFontFamily,
    double? titleFontSize,
    bool? titleIsBold,
    bool? titleIsItalic,
    bool clearTitleFontColor = false,
    bool clearTitleFontFamily = false,
    bool clearTitleFontSize = false,
    bool clearTitleIsBold = false,
    bool clearTitleIsItalic = false,
  }) {
    return NoteStyle(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontColor: fontColor ?? this.fontColor,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isStrikethrough: isStrikethrough ?? this.isStrikethrough,
      titleFontColor:
          clearTitleFontColor ? null : (titleFontColor ?? this.titleFontColor),
      titleFontFamily:
          clearTitleFontFamily
              ? null
              : (titleFontFamily ?? this.titleFontFamily),
      titleFontSize:
          clearTitleFontSize ? null : (titleFontSize ?? this.titleFontSize),
      titleIsBold: clearTitleIsBold ? null : (titleIsBold ?? this.titleIsBold),
      titleIsItalic:
          clearTitleIsItalic ? null : (titleIsItalic ?? this.titleIsItalic),
    );
  }

  Map<String, dynamic> toJson() => {
    'fontFamily': fontFamily,
    'fontSize': fontSize,
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.toARGB32(),
    if (fontColor != null) 'fontColor': fontColor!.toARGB32(),
    'isBold': isBold,
    'isItalic': isItalic,
    'isStrikethrough': isStrikethrough,
    if (titleFontColor != null) 'titleFontColor': titleFontColor!.toARGB32(),
    if (titleFontFamily != null) 'titleFontFamily': titleFontFamily,
    if (titleFontSize != null) 'titleFontSize': titleFontSize,
    if (titleIsBold != null) 'titleIsBold': titleIsBold,
    if (titleIsItalic != null) 'titleIsItalic': titleIsItalic,
  };

  factory NoteStyle.fromJson(Map<String, dynamic> json) => NoteStyle(
    fontFamily: json['fontFamily'] as String? ?? 'Exo 2',
    fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
    backgroundColor:
        json['backgroundColor'] != null
            ? Color(json['backgroundColor'] as int)
            : null,
    fontColor:
        json['fontColor'] != null ? Color(json['fontColor'] as int) : null,
    isBold: json['isBold'] as bool? ?? false,
    isItalic: json['isItalic'] as bool? ?? false,
    isStrikethrough: json['isStrikethrough'] as bool? ?? false,
    titleFontColor:
        json['titleFontColor'] != null
            ? Color(json['titleFontColor'] as int)
            : null,
    titleFontFamily: json['titleFontFamily'] as String?,
    titleFontSize: (json['titleFontSize'] as num?)?.toDouble(),
    titleIsBold: json['titleIsBold'] as bool?,
    titleIsItalic: json['titleIsItalic'] as bool?,
  );
}

class NoteModel {
  final String id;
  String title;
  String content;
  NoteType type;
  NoteStyle style;
  List<ChecklistItem> checklistItems;
  List<AudioNote> audioNotes;
  bool isArchived;
  bool isPinned;
  bool isLocked;
  DateTime? reminder;
  List<String> linkedNoteIds;
  List<String> tags;
  final DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;

  NoteModel({
    String? id,
    this.title = '',
    this.content = '',
    this.type = NoteType.note,
    NoteStyle? style,
    List<ChecklistItem>? checklistItems,
    List<AudioNote>? audioNotes,
    this.isArchived = false,
    this.isPinned = false,
    this.isLocked = false,
    this.reminder,
    List<String>? linkedNoteIds,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : id = id ?? const Uuid().v4(),
       style = style ?? const NoteStyle(),
       checklistItems = checklistItems ?? [],
       audioNotes = audioNotes ?? [],
       linkedNoteIds = linkedNoteIds ?? [],
       tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  NoteModel copyWith({
    String? title,
    String? content,
    NoteType? type,
    NoteStyle? style,
    List<ChecklistItem>? checklistItems,
    List<AudioNote>? audioNotes,
    bool? isArchived,
    bool? isPinned,
    bool? isLocked,
    DateTime? reminder,
    bool clearReminder = false,
    List<String>? linkedNoteIds,
    List<String>? tags,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      style: style ?? this.style,
      checklistItems: checklistItems ?? this.checklistItems,
      audioNotes: audioNotes ?? this.audioNotes,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      reminder: clearReminder ? null : (reminder ?? this.reminder),
      linkedNoteIds: linkedNoteIds ?? this.linkedNoteIds,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'type': type.name,
    'style': style.toJson(),
    'checklistItems': checklistItems.map((e) => e.toJson()).toList(),
    'audioNotes': audioNotes.map((e) => e.toJson()).toList(),
    'isArchived': isArchived,
    'isPinned': isPinned,
    'isLocked': isLocked,
    if (reminder != null) 'reminder': reminder!.toIso8601String(),
    'linkedNoteIds': linkedNoteIds,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: json['id'] as String?,
    title: json['title'] as String? ?? '',
    content: json['content'] as String? ?? '',
    type: NoteType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => NoteType.note,
    ),
    style:
        json['style'] != null
            ? NoteStyle.fromJson(json['style'] as Map<String, dynamic>)
            : const NoteStyle(),
    checklistItems:
        (json['checklistItems'] as List<dynamic>?)
            ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    audioNotes:
        (json['audioNotes'] as List<dynamic>?)
            ?.map((e) => AudioNote.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    isArchived: json['isArchived'] as bool? ?? false,
    isPinned: json['isPinned'] as bool? ?? false,
    isLocked: json['isLocked'] as bool? ?? false,
    reminder:
        json['reminder'] != null
            ? DateTime.parse(json['reminder'] as String)
            : null,
    linkedNoteIds:
        (json['linkedNoteIds'] as List<dynamic>?)?.cast<String>() ?? [],
    tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    createdAt:
        json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
    updatedAt:
        json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
    deletedAt:
        json['deletedAt'] != null
            ? DateTime.parse(json['deletedAt'] as String)
            : null,
  );
}
