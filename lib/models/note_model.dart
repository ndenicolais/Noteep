import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NoteModel {
  String id;
  String title;
  String content;
  Color backgroundColor;
  Color textColor;
  String font;
  List<String> attachments;
  DateTime? notificationTime;
  DateTime dateAdded;

  NoteModel({
    this.id = '',
    required this.title,
    required this.content,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.font = 'Exo 2',
    this.attachments = const [],
    this.notificationTime,
  }) : dateAdded = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'backgroundColor': backgroundColor.value,
      'textColor': textColor.value,
      'font': font,
      'attachments': attachments,
      'notificationTime': notificationTime?.toIso8601String(),
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory NoteModel.fromDocument(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      backgroundColor: Color(data['backgroundColor'] ?? Colors.white.value),
      textColor: Color(data['textColor'] ?? Colors.black.value),
      font: data['font'] ?? 'Exo 2',
      attachments: List<String>.from(data['attachments'] ?? []),
      notificationTime: data['notificationTime'] != null
          ? DateTime.parse(data['notificationTime'])
          : null,
    )..dateAdded = data['dateAdded'] != null
        ? DateTime.parse(data['dateAdded'])
        : DateTime.now();
  }
}
