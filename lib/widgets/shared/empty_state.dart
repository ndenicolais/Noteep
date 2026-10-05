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
import '../../theme/app_font_sizes.dart';

/// Shared icon+message placeholder for empty/error list states.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.iconSize = 80,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final double iconSize;

  /// Optional call-to-action button shown under the message (e.g. "Riprova"
  /// on a sync error, "Crea la prima nota" on an empty list). Shown only when
  /// both [actionLabel] and [onAction] are set.
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.outline,
              fontSize: AppFontSizes.lg,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: onAction,
              icon: Icon(actionIcon ?? Icons.arrow_forward),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
