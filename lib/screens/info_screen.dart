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
import '../core/constants/app_info.dart';
import '../core/constants/app_version.dart';
import '../core/routing/app_router.dart';
import '../theme/app_spacing.dart';
import '../utils/link_utils.dart';
import '../widgets/changelog_dialog.dart';
import '../widgets/shared/app_logo.dart';

const _appName = 'Noteep';

/// Gap between the header, the description card and the credits.
const _blockGap = 28.0;

/// About the app: identity, what it does, useful links and credits.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.infoTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _Header(),
                const SizedBox(height: _blockGap),

                // ── Cos'è Noteep ─────────────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.infoAboutTitle,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.infoDescription,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Funzionalità ─────────────────────────────────────────
                _SectionLabel(context.l10n.infoFeaturesTitle),
                const _FeatureGrid(),

                // ── Link ─────────────────────────────────────────────────
                _SectionLabel(context.l10n.infoLinksTitle),
                const _LinksCard(),
                const SizedBox(height: _blockGap),

                // ── Crediti ──────────────────────────────────────────────
                Text(
                  context.l10n.infoMadeBy(developerName),
                  textAlign: TextAlign.center,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      children: [
        const AppLogo(size: 96),
        const SizedBox(height: AppSpacing.md),
        Text(
          _appName,
          style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.infoTagline,
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.infoVersion(appVersion, appBuildNumber),
          style: tt.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.xl,
          0,
          AppSpacing.sm,
        ),
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

typedef _Feature = ({IconData icon, String title, String text});

/// Two-by-two grid of the main features (keep an even count).
class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final List<_Feature> features = [
      (
        icon: Icons.sticky_note_2_outlined,
        title: l10n.infoFeatureNotesTitle,
        text: l10n.infoFeatureNotesText,
      ),
      (
        icon: Icons.event_available_outlined,
        title: l10n.infoFeatureTasksTitle,
        text: l10n.infoFeatureTasksText,
      ),
      (
        icon: Icons.notifications_active_outlined,
        title: l10n.infoFeatureRemindersTitle,
        text: l10n.infoFeatureRemindersText,
      ),
      (
        icon: Icons.cloud_sync_outlined,
        title: l10n.infoFeatureSyncTitle,
        text: l10n.infoFeatureSyncText,
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < features.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _FeatureCard(features[i])),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _FeatureCard(features[i + 1])),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard(this.feature);

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    // Cards in a grid row have no outer margin: the row gap spaces them.
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBadge(feature.icon),
            const SizedBox(height: AppSpacing.md),
            Text(
              feature.title,
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              feature.text,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// 36×36 tile with the icon in the brand color, shared by features and links.
class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final brand = Theme.of(context).colorScheme.primary;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: brand.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: brand),
    );
  }
}

class _LinksCard extends StatelessWidget {
  const _LinksCard();

  Future<void> _open(BuildContext context, Uri uri) async {
    // Read context-dependent objects before the async gap.
    final messenger = ScaffoldMessenger.of(context);
    final error = context.l10n.infoLinkError;
    final opened = await openExternalLink(uri.toString());
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = [
      _LinkRow(
        icon: Icons.code,
        text: l10n.infoLinkSource,
        external: true,
        onTap: () => _open(context, uriSourceCode),
      ),
      _LinkRow(
        icon: Icons.person_outline,
        text: l10n.infoLinkDeveloper,
        external: true,
        onTap: () => _open(context, uriDeveloperGithub),
      ),
      _LinkRow(
        icon: Icons.mail_outline,
        text: l10n.infoLinkContact,
        external: true,
        onTap: () => _open(context, uriContactMail),
      ),
      _LinkRow(
        icon: Icons.school_outlined,
        text: l10n.infoGuideOpen,
        onTap: () => AppNav.openOnboarding(context),
      ),
      _LinkRow(
        icon: Icons.history_outlined,
        text: l10n.infoChangelogTitle,
        onTap: () => showChangelogDialog(context),
      ),
      _LinkRow(
        icon: Icons.privacy_tip_outlined,
        text: l10n.infoPrivacyOpen,
        onTap: () => AppNav.openPrivacyPolicy(context),
      ),
      _LinkRow(
        icon: Icons.article_outlined,
        text: l10n.infoLicensesTitle,
        onTap:
            () => showLicensePage(
              context: context,
              applicationName: _appName,
              applicationVersion: appVersion,
              applicationIcon: const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: AppLogo(size: 64),
              ),
            ),
      ),
    ];

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            // Indent aligns the divider with the text, past the icon badge.
            if (i > 0) const Divider(height: 1, indent: 16 + 36 + 16),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.text,
    required this.onTap,
    this.external = false,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  /// Shows an "opens outside the app" arrow instead of a chevron.
  final bool external;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: _IconBadge(icon),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Icon(
        external ? Icons.north_east : Icons.chevron_right,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
