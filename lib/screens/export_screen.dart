// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../utils/downloader.dart';

class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeNotes = ref.watch(activeNotesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Esporta note')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Esporta tutte le note attive (escluse quelle nel cestino).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _ExportTile(
            icon: Icons.picture_as_pdf_outlined,
            label: 'PDF',
            subtitle: 'Salva le note in un file .pdf',
            onTap: () => _exportPdf(context, activeNotes),
          ),
          _ExportTile(
            icon: Icons.text_snippet_outlined,
            label: 'TXT',
            subtitle: 'Salva le note in un file .txt',
            onTap: () => _exportText(context, activeNotes),
          ),
          _ExportTile(
            icon: Icons.data_object,
            label: 'JSON',
            subtitle: 'Salva le note in un file .json',
            onTap: () => _exportJson(context, activeNotes),
          ),
          _ExportTile(
            icon: Icons.table_chart_outlined,
            label: 'CSV',
            subtitle: 'Salva le note in un file .csv',
            onTap: () => _exportCsv(context, activeNotes),
          ),
          _ExportTile(
            icon: Icons.html,
            label: 'HTML',
            subtitle: 'Salva le note in un file .html',
            onTap: () => _exportHtml(context, activeNotes),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Export helpers ──────────────────────────────────────────────────────────

  Future<void> _exportPdf(BuildContext context, List<NoteModel> notes) async {
    final doc = pw.Document();
    final dateFormat = DateFormat("d MMM y 'alle' HH:mm", 'it');
    for (final note in notes) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build:
              (ctx) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (note.title.isNotEmpty) ...[
                    pw.Text(
                      note.title,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                  ],
                  pw.Text(note.content.isEmpty ? '(nota vuota)' : note.content),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Modificata: ${dateFormat.format(note.updatedAt)}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                  if (note.tags.isNotEmpty)
                    pw.Text(
                      'Etichette: ${note.tags.join(', ')}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  pw.Divider(),
                ],
              ),
        ),
      );
    }
    try {
      await Printing.layoutPdf(
        onLayout: (_) async => doc.save(),
        name: 'note_export.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore PDF: $e')));
      }
    }
  }

  Future<void> _exportText(BuildContext context, List<NoteModel> notes) async {
    final fmt = DateFormat('d MMM y HH:mm', 'it');
    final buf = StringBuffer();
    for (final n in notes) {
      if (n.title.isNotEmpty) buf.writeln('=== ${n.title} ===');
      buf.writeln(n.content.isEmpty ? '(nota vuota)' : n.content);
      buf.writeln('Modificata: ${fmt.format(n.updatedAt)}');
      buf.writeln('---\n');
    }
    await _saveOrDownload(
      context,
      content: buf.toString(),
      fileName: 'note_export.txt',
      mimeType: 'text/plain',
      label: 'TXT',
    );
  }

  Future<void> _exportJson(BuildContext context, List<NoteModel> notes) async {
    final list =
        notes
            .map(
              (n) => {
                'id': n.id,
                'title': n.title,
                'content': n.content.isEmpty ? '(nota vuota)' : n.content,
                'type': n.type.name,
                'tags': n.tags,
                'isPinned': n.isPinned,
                'createdAt': n.createdAt.toIso8601String(),
                'updatedAt': n.updatedAt.toIso8601String(),
              },
            )
            .toList();
    final json = const JsonEncoder.withIndent('  ').convert(list);
    await _saveOrDownload(
      context,
      content: json,
      fileName: 'note_export.json',
      mimeType: 'application/json',
      label: 'JSON',
    );
  }

  Future<void> _exportCsv(BuildContext context, List<NoteModel> notes) async {
    String esc(String s) =>
        '"${s.replaceAll('"', '""').replaceAll('\n', ' ')}"';
    final buf = StringBuffer();
    buf.writeln('id,titolo,contenuto,tipo,etichette,fissata,creata,modificata');
    for (final n in notes) {
      buf.writeln(
        [
          esc(n.id),
          esc(n.title),
          esc(n.content.isEmpty ? '(nota vuota)' : n.content),
          esc(n.type.name),
          esc(n.tags.join(';')),
          n.isPinned ? '1' : '0',
          esc(n.createdAt.toIso8601String()),
          esc(n.updatedAt.toIso8601String()),
        ].join(','),
      );
    }
    await _saveOrDownload(
      context,
      content: buf.toString(),
      fileName: 'note_export.csv',
      mimeType: 'text/csv',
      label: 'CSV',
    );
  }

  Future<void> _exportHtml(BuildContext context, List<NoteModel> notes) async {
    final fmt = DateFormat('d MMM y HH:mm', 'it');
    final buf =
        StringBuffer()..writeln(
          '''<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <title>Note Export</title>
  <style>
    body { font-family: sans-serif; max-width: 800px; margin: 2rem auto; }
    article { border: 1px solid #ddd; border-radius: 8px; padding: 1rem; margin-bottom: 1.5rem; }
    h2 { margin: 0 0 .5rem; }
    .meta { font-size: .75rem; color: #888; margin-top: .5rem; }
    .tag { background: #e8f4f8; border-radius: 4px; padding: 2px 6px; font-size: .7rem; margin-right: 4px; }
  </style>
</head>
<body>
  <h1>Export note – ${DateFormat('d MMM y', 'it').format(DateTime.now())}</h1>''',
        );

    for (final n in notes) {
      buf.writeln('  <article>');
      if (n.title.isNotEmpty) {
        buf.writeln('    <h2>${_he(n.title)}</h2>');
      }
      buf.writeln(
        '    <p>${_he(n.content.isEmpty ? '(nota vuota)' : n.content)}</p>',
      );
      if (n.tags.isNotEmpty) {
        buf.write('    <p>');
        for (final t in n.tags) {
          buf.write('<span class="tag">${_he(t)}</span>');
        }
        buf.writeln('</p>');
      }
      buf.writeln(
        '    <p class="meta">Modificata: ${fmt.format(n.updatedAt)}</p>',
      );
      buf.writeln('  </article>');
    }
    buf.writeln('</body>\n</html>');

    await _saveOrDownload(
      context,
      content: buf.toString(),
      fileName: 'note_export.html',
      mimeType: 'text/html',
      label: 'HTML',
    );
  }

  String _he(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  Future<void> _saveOrDownload(
    BuildContext context, {
    required String content,
    required String fileName,
    required String mimeType,
    required String label,
  }) async {
    final bytes = utf8.encode(content);
    final savedPath = await downloadFile(bytes, fileName, mimeType);
    if (!context.mounted) return;
    final msg =
        kIsWeb
            ? '$label scaricato'
            : savedPath != null
            ? '$label salvato in:\n$savedPath'
            : '$label esportato';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }
}

// ─── Export Tile ─────────────────────────────────────────────────────────────

class _ExportTile extends StatelessWidget {
  const _ExportTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: onTap,
        tooltip: 'Scarica',
      ),
    );
  }
}
