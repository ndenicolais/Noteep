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
import 'settings_section_header.dart';

/// "Google Drive" section: coming-soon sync entry point.
class SettingsGoogleDriveSection extends StatelessWidget {
  const SettingsGoogleDriveSection({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SettingsSectionHeader(title: 'Google Drive'),
        ListTile(
          leading: Icon(
            Icons.cloud_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Collega Google Drive'),
          subtitle: const Text(
            'Sincronizza i backup con il tuo account Google',
          ),
          trailing: const Icon(Icons.chevron_right),
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
    return ListTile(
      leading: Icon(
        Icons.info_outline,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('Info app'),
      subtitle: const Text('Informazioni sull\'app e sulla versione'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => AppNav.openInfo(context),
    );
  }
}
