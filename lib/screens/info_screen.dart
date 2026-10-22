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
import '../core/constants/app_version.dart';
import '../theme/app_spacing.dart';
import '../widgets/changelog_dialog.dart';
import '../widgets/shared/app_logo.dart';
import '../widgets/shared/section_header.dart';
import '../widgets/shared/tag_chip.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Info app')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        children: [
          // ── Logo + Nome ──────────────────────────────────────────────────
          const SizedBox(height: AppSpacing.lg),
          const Center(child: AppLogo(size: 96)),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Noteep',
              style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'Versione $appVersion (build $appBuildNumber)',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Descrizione ──────────────────────────────────────────────────
          const SectionHeader('Descrizione', padding: EdgeInsets.zero),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Noteep è un\'app per prendere note, creare liste di controllo '
            'e gestire le tue idee in modo semplice e veloce. '
            'Supporta temi chiaro e scuro, stili di testo personalizzati, '
            'etichette, archivio e molto altro.',
            style: tt.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Funzionalità ─────────────────────────────────────────────────
          const SectionHeader('Funzionalità', padding: EdgeInsets.zero),
          const SizedBox(height: AppSpacing.sm),
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
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(item.$1, size: 20, color: cs.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(item.$2, style: tt.bodyMedium)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Tecnologie ───────────────────────────────────────────────────
          const SectionHeader('Tecnologie', padding: EdgeInsets.zero),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TagChip('Flutter'),
              TagChip('Dart'),
              TagChip('Riverpod'),
              TagChip('Material 3'),
              TagChip('SharedPreferences'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Changelog ────────────────────────────────────────────────────
          const SectionHeader('Changelog', padding: EdgeInsets.zero),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.history_outlined, color: cs.primary),
            title: const Text('Visualizza changelog'),
            subtitle: const Text('Le modifiche di ogni versione'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showChangelogDialog(context),
          ),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),

          // ── Licenze ──────────────────────────────────────────────────────
          const SectionHeader('Licenze open source', padding: EdgeInsets.zero),
          const SizedBox(height: AppSpacing.sm),
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
                  applicationVersion: appVersion,
                  applicationIcon: const Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: AppLogo(size: 48),
                  ),
                ),
          ),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xxl),

          // ── Copyright ────────────────────────────────────────────────────
          Center(
            child: Text(
              '© ${DateTime.now().year} Noteep',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
