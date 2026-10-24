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
import 'package:intl/intl.dart';
import '../core/constants/app_info.dart';
import '../l10n/l10n.dart';
import '../theme/app_spacing.dart';
import '../utils/link_utils.dart';

/// Native, localized copy of `PRIVACY.md`: same 10 sections, same date.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static List<(String, String)> _sections(AppLocalizations l) => [
    (
      l.policy_section_controller_title,
      l.policy_section_controller_text(developerName, developerEmail),
    ),
    (l.policy_section_data_title, l.policy_section_data_text),
    (l.policy_section_use_title, l.policy_section_use_text),
    (l.policy_section_storage_title, l.policy_section_storage_text),
    (l.policy_section_device_title, l.policy_section_device_text),
    (l.policy_section_permissions_title, l.policy_section_permissions_text),
    (
      l.policy_section_retention_title,
      l.policy_section_retention_text(developerEmail),
    ),
    (
      l.policy_section_rights_title,
      l.policy_section_rights_text(developerEmail),
    ),
    (l.policy_section_children_title, l.policy_section_children_text),
    (l.policy_section_changes_title, l.policy_section_changes_text),
  ];

  Future<void> _openOnline(BuildContext context) async {
    final opened = await openExternalLink(uriPrivacyPolicy.toString());
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.commonLinkOpenFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final date = DateFormat.yMMMMd(l.localeName).format(privacyPolicyUpdatedAt);

    return Scaffold(
      appBar: AppBar(title: Text(l.privacyPolicyTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        children: [
          Text(
            l.privacyPolicyLastUpdated(date),
            style: tt.labelLarge?.copyWith(color: cs.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l.privacyPolicyIntro, style: tt.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          for (final (title, text) in _sections(l))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SelectableText(text, style: tt.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.public, color: cs.primary),
            title: Text(l.privacyPolicyOnlineVersion),
            subtitle: Text(l.privacyPolicyOnlineVersionSubtitle),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openOnline(context),
          ),
        ],
      ),
    );
  }
}
