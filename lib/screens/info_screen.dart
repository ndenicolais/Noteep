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

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static const _version = '1.0.0';
  static const _buildNumber = '1';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Info app')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // ── Logo + Nome ──────────────────────────────────────────────────
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.note_alt_outlined,
                size: 56,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Noteep',
              style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'Versione $_version (build $_buildNumber)',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 32),

          // ── Descrizione ──────────────────────────────────────────────────
          _SectionHeader(label: 'Descrizione'),
          const SizedBox(height: 8),
          Text(
            'Noteep è un\'app per prendere note, creare liste di controllo '
            'e gestire le tue idee in modo semplice e veloce. '
            'Supporta temi chiaro e scuro, stili di testo personalizzati, '
            'etichette, archivio e molto altro.',
            style: tt.bodyMedium,
          ),
          const SizedBox(height: 24),

          // ── Funzionalità ─────────────────────────────────────────────────
          _SectionHeader(label: 'Funzionalità'),
          const SizedBox(height: 8),
          ...[
            (Icons.note_outlined, 'Note di testo con formattazione'),
            (Icons.checklist_outlined, 'Liste di controllo interattive'),
            (Icons.label_outline, 'Etichette personalizzate'),
            (Icons.archive_outlined, 'Archivio e cestino'),
            (Icons.dark_mode_outlined, 'Tema chiaro, scuro e di sistema'),
            (
              Icons.upload_file_outlined,
              'Esportazione in PDF, TXT, JSON, CSV, HTML',
            ),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(item.$1, size: 20, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item.$2, style: tt.bodyMedium)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Tecnologie ───────────────────────────────────────────────────
          _SectionHeader(label: 'Tecnologie'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TechChip(label: 'Flutter'),
              _TechChip(label: 'Dart'),
              _TechChip(label: 'Riverpod'),
              _TechChip(label: 'Material 3'),
              _TechChip(label: 'SharedPreferences'),
            ],
          ),
          const SizedBox(height: 24),

          // ── Licenze ──────────────────────────────────────────────────────
          _SectionHeader(label: 'Licenze open source'),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.article_outlined, color: cs.primary),
            title: const Text('Visualizza licenze'),
            subtitle: const Text('Librerie di terze parti utilizzate'),
            trailing: const Icon(Icons.chevron_right),
            onTap:
                () => showLicensePage(
                  context: context,
                  applicationName: 'Noteep',
                  applicationVersion: _version,
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.note_alt_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 32),

          // ── Copyright ────────────────────────────────────────────────────
          Center(
            child: Text(
              '© ${DateTime.now().year} Noteep',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      side: BorderSide.none,
    );
  }
}
