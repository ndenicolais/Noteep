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
import '../l10n/l10n.dart';
import '../core/constants/app_version.dart';
import '../core/routing/app_router.dart';
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
      appBar: AppBar(title: Text(context.l10n.infoTitle)),
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
              context.l10n.infoVersion(appVersion, appBuildNumber),
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Descrizione ──────────────────────────────────────────────────
          SectionHeader(
            context.l10n.infoDescriptionTitle,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(context.l10n.infoDescription, style: tt.bodyMedium),
          const SizedBox(height: AppSpacing.xl),

          // ── Funzionalità ─────────────────────────────────────────────────
          SectionHeader(
            context.l10n.infoFeaturesTitle,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...[
            (Icons.note_outlined, context.l10n.infoFeatureNotes),
            (Icons.checklist_outlined, context.l10n.infoFeatureChecklists),
            (Icons.label_outline, context.l10n.infoFeatureLabels),
            (Icons.archive_outlined, context.l10n.infoFeatureArchive),
            (Icons.dark_mode_outlined, context.l10n.infoFeatureTheme),
            (Icons.upload_file_outlined, context.l10n.infoFeatureExport),
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
          SectionHeader(context.l10n.infoTechTitle, padding: EdgeInsets.zero),
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

          // ── Guida ────────────────────────────────────────────────────────
          SectionHeader(context.l10n.infoGuideTitle, padding: EdgeInsets.zero),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.school_outlined, color: cs.primary),
            title: Text(context.l10n.infoGuideOpen),
            subtitle: Text(context.l10n.infoGuideSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => AppNav.openOnboarding(context),
          ),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),

          // ── Changelog ────────────────────────────────────────────────────
          SectionHeader(
            context.l10n.infoChangelogTitle,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.history_outlined, color: cs.primary),
            title: Text(context.l10n.infoChangelogOpen),
            subtitle: Text(context.l10n.infoChangelogSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showChangelogDialog(context),
          ),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),

          // ── Licenze ──────────────────────────────────────────────────────
          SectionHeader(
            context.l10n.infoLicensesTitle,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.article_outlined, color: cs.primary),
            title: Text(context.l10n.infoLicensesOpen),
            subtitle: Text(context.l10n.infoLicensesSubtitle),
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
