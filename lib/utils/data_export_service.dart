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
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Where an exported file goes.
enum ExportDestination {
  /// System "Save as" dialog: the user picks the folder (Downloads, Drive,
  /// SD card...). On web it starts a browser download.
  device,

  /// System share sheet (Drive, email, chat...). Not available on web.
  share,
}

enum ExportOutcome { saved, shared, cancelled }

/// File writing, sharing and picking for the import/export/backup features,
/// kept out of the widget layer. Nothing is ever written to a folder chosen
/// by the app: the user always picks the destination.
class DataExportService {
  /// `<prefix>_yyyyMMdd_HHmmss.<extension>`.
  static String timestampedName(String prefix, String extension) {
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${prefix}_$dateStr.$extension';
  }

  /// Sends [bytes] to [destination] as [fileName].
  static Future<ExportOutcome> exportBytes({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    required ExportDestination destination,
  }) async {
    final data = Uint8List.fromList(bytes);
    switch (destination) {
      case ExportDestination.device:
        final uri = await FilePicker.saveFile(
          fileName: fileName,
          bytes: data,
          mimeType: mimeType,
        );
        return uri == null ? ExportOutcome.cancelled : ExportOutcome.saved;
      case ExportDestination.share:
        // A real file with the final name: with XFile.fromData some targets
        // give the shared file a generic internal name.
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(data);
        final result = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: mimeType)],
            // Some targets (e.g. "Save to Drive") name the document after
            // the subject instead of the file.
            subject: fileName,
          ),
        );
        // Some platforms report `unavailable` even when the file was sent:
        // only an explicit dismissal counts as cancelled.
        return result.status == ShareResultStatus.dismissed
            ? ExportOutcome.cancelled
            : ExportOutcome.shared;
    }
  }

  /// Encodes [data] as pretty JSON and exports it as a timestamped
  /// `<fileNamePrefix>_yyyyMMdd_HHmmss.json` file.
  static Future<ExportOutcome> exportJson({
    required Map<String, dynamic> data,
    required String fileNamePrefix,
    required ExportDestination destination,
  }) {
    final json = const JsonEncoder.withIndent('  ').convert(data);
    return exportBytes(
      bytes: utf8.encode(json),
      fileName: timestampedName(fileNamePrefix, 'json'),
      mimeType: 'application/json',
      destination: destination,
    );
  }

  /// Exports [content] as an ICS file named [fileName].
  static Future<ExportOutcome> exportIcs(
    String content,
    String fileName,
    ExportDestination destination,
  ) => exportBytes(
    bytes: utf8.encode(content),
    fileName: fileName,
    mimeType: 'text/calendar',
    destination: destination,
  );

  /// Opens a file picker for a single `.json` file and returns its decoded
  /// content, or null if the user cancelled. Throws [FormatException] if the
  /// file isn't a JSON object.
  static Future<Map<String, dynamic>?> pickAndDecodeJson() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Not a JSON object');
    }
    return decoded;
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
