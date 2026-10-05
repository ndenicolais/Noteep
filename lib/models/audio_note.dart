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

class AudioNote {
  final String id;
  final String filename;
  final String filepath;
  final Duration duration;
  final DateTime createdAt;
  final String? transcription;

  AudioNote({
    String? id,
    required this.filename,
    required this.filepath,
    required this.duration,
    DateTime? createdAt,
    this.transcription,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  AudioNote copyWith({
    String? filename,
    String? filepath,
    Duration? duration,
    DateTime? createdAt,
    String? transcription,
    bool clearTranscription = false,
  }) {
    return AudioNote(
      id: id,
      filename: filename ?? this.filename,
      filepath: filepath ?? this.filepath,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      transcription:
          clearTranscription ? null : (transcription ?? this.transcription),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'filename': filename,
    'filepath': filepath,
    'duration': duration.inMilliseconds,
    'createdAt': createdAt.toIso8601String(),
    if (transcription != null) 'transcription': transcription,
  };

  factory AudioNote.fromJson(Map<String, dynamic> json) => AudioNote(
    id: json['id'] as String?,
    filename: json['filename'] as String,
    filepath: json['filepath'] as String,
    duration: Duration(milliseconds: json['duration'] as int? ?? 0),
    createdAt: DateTime.parse(json['createdAt'] as String),
    transcription: json['transcription'] as String?,
  );
}
