// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../../core/constants/app_version.dart';
import '../../core/routing/app_router.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../widgets/shared/action_tile.dart';
import '../../widgets/shared/section_header.dart';

/// "Google Drive" section: coming-soon sync entry point.
class SettingsGoogleDriveSection extends StatelessWidget {
  const SettingsGoogleDriveSection({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(context.l10n.settingsGoogleDriveTitle),
        ActionTile(
          icon: Icons.cloud_outlined,
          title: context.l10n.settingsConnectDrive,
          subtitle: context.l10n.settingsConnectDriveSubtitle,
          onTap: onTap,
        ),
      ],
    );
  }
}

/// "Account" section: permanent deletion of the account and all its data.
class SettingsAccountSection extends StatelessWidget {
  const SettingsAccountSection({super.key, required this.onDeleteAccount});

  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(context.l10n.settingsAccountTitle),
        ActionTile(
          icon: Icons.person_remove_outlined,
          title: context.l10n.settingsDeleteAccount,
          subtitle: context.l10n.settingsDeleteAccountSubtitle,
          destructive: true,
          onTap: onDeleteAccount,
        ),
      ],
    );
  }
}

/// "Informazioni" section: link to the app info screen.
class SettingsInfoSection extends StatelessWidget {
  const SettingsInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionTile(
      icon: Icons.info_outline,
      title: context.l10n.infoTitle,
      subtitle: context.l10n.infoVersion(appVersion),
      onTap: () => AppNav.openInfo(context),
    );
  }
}
