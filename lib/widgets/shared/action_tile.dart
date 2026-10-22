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

/// A tappable row that runs an action or opens a screen: leading icon in
/// the primary color, title, optional subtitle and a chevron. With
/// [destructive] the icon and title use the error color (clear/delete).
class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.destructive = false,
    required this.onTap,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;

  /// Replaces the default chevron.
  final Widget? trailing;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = destructive ? cs.error : cs.primary;
    return ListTile(
      leading: icon == null ? null : Icon(icon, color: accent),
      title: Text(
        title,
        style: destructive ? TextStyle(color: cs.error) : null,
      ),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
