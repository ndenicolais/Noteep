// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import '../../core/routing/app_router.dart';
import 'package:flutter/material.dart';
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
        const SectionHeader('Google Drive'),
        ActionTile(
          icon: Icons.cloud_outlined,
          title: 'Collega Google Drive',
          subtitle: 'Sincronizza i backup con il tuo account Google',
          onTap: onTap,
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
      title: 'Info app',
      subtitle: 'Informazioni sull\'app e sulla versione',
      onTap: () => AppNav.openInfo(context),
    );
  }
}
