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
import '../../theme/app_spacing.dart';

/// Title of a group of rows (settings sections, reminder groups, info
/// blocks, "Completati" in Tasks), in the primary color with an optional
/// leading [icon]. Announced as a header by screen readers.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.icon,
    this.muted = false,
    this.padding = listPadding,
  });

  /// Inset for a header above full-width list tiles.
  static const listPadding = EdgeInsets.fromLTRB(
    AppSpacing.lg,
    AppSpacing.xl,
    AppSpacing.lg,
    AppSpacing.xs,
  );

  /// For a header inside an already padded column.
  static const inlinePadding = EdgeInsets.symmetric(vertical: AppSpacing.sm);

  final String title;
  final IconData? icon;

  /// Uses the outline color instead of primary, for secondary groupings.
  final bool muted;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = muted ? cs.outline : cs.primary;
    return Semantics(
      header: true,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
