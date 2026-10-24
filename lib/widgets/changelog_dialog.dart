// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import '../core/constants/changelog.dart';
import '../l10n/l10n.dart';
import '../theme/app_spacing.dart';

/// Shows [entries], or the whole history when null.
Future<void> showChangelogDialog(
  BuildContext context, {
  List<ChangelogEntry>? entries,
}) {
  return showDialog(
    context: context,
    builder: (_) => ChangelogDialog(entries: entries ?? changelogEntries),
  );
}

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({super.key, required this.entries});

  final List<ChangelogEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tt = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(l10n.changelog_dialog_title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in entries) ...[
              Text(
                'v${entry.version}',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              for (final section in entry.sections.entries) ...[
                const SizedBox(height: AppSpacing.md),
                _SectionHeader(type: section.key),
                const SizedBox(height: 6),
                for (final item in section.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(item.textBuilder(l10n))),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.changelog_dialog_close),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.type});

  final ChangeType type;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = Theme.of(context).colorScheme.primary;
    final (icon, label) = switch (type) {
      ChangeType.added => (
        Icons.auto_awesome_outlined,
        l10n.changelog_section_added,
      ),
      ChangeType.improved => (
        Icons.rocket_launch_outlined,
        l10n.changelog_section_improved,
      ),
      ChangeType.fixed => (
        Icons.bug_report_outlined,
        l10n.changelog_section_fixed,
      ),
      ChangeType.security => (
        Icons.shield_outlined,
        l10n.changelog_section_security,
      ),
    };
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
