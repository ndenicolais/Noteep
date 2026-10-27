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

/// A label the user created, stored even when no note uses it yet. Notes
/// reference labels by [name] (see `NoteModel.tags`).
class LabelModel {
  final String id;
  final String name;
  final DateTime createdAt;

  LabelModel({String? id, required this.name, DateTime? createdAt})
    : id = id ?? const Uuid().v4(),
      createdAt = createdAt ?? DateTime.now();

  LabelModel copyWith({String? name}) =>
      LabelModel(id: id, name: name ?? this.name, createdAt: createdAt);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory LabelModel.fromJson(Map<String, dynamic> json) => LabelModel(
    id: json['id'] as String?,
    name: json['name'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
