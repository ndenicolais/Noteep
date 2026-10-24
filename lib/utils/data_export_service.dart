// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'downloader.dart';

/// JSON/ICS encode-decode and file picking/writing for the Settings screen's
/// import/export/backup features, kept out of the widget layer.
class DataExportService {
  /// Encodes [buildData] as pretty JSON and writes it to a timestamped
  /// `<fileNamePrefix>_yyyyMMdd_HHmmss.json` file. Returns the saved path
  /// (null on web, where the browser handles the download directly).
  static Future<String?> exportJson({
    required Map<String, dynamic> Function() buildData,
    required String fileNamePrefix,
  }) async {
    final data = buildData();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = utf8.encode(json);
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${fileNamePrefix}_$dateStr.json';
    return downloadFile(bytes, fileName, 'application/json');
  }

  /// Opens a file picker for a single `.json` file and returns its decoded
  /// content, or null if the user cancelled or picked an empty file.
  static Future<Map<String, dynamic>?> pickAndDecodeJson() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }

  /// Writes [content] to `fileName` with an ICS mime type. Returns the saved
  /// path (null on web).
  static Future<String?> exportIcs(String content, String fileName) {
    final bytes = utf8.encode(content);
    return downloadFile(bytes, fileName, 'text/calendar');
  }

  /// Opens a file picker for a single `.ics` file and returns its decoded
  /// text content, or null if the user cancelled or picked an empty file.
  static Future<String?> pickIcsContent() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['ics'],
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return utf8.decode(bytes);
  }
}
