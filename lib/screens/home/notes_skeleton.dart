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
import '../../providers/settings/ui_provider.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/shared/skeleton.dart';
import 'home_layout_utils.dart';

/// First-load placeholder for the Home: grey note cards laid out like the
/// real grid/list (same paddings and column count), so the layout doesn't
/// jump when the notes arrive.
class NotesSkeleton extends StatelessWidget {
  const NotesSkeleton({super.key, required this.layout});

  final HomeLayout layout;

  // Varying card heights so the grid doesn't read as a table.
  static const _gridHeights = [140.0, 96.0, 180.0, 120.0, 160.0, 104.0];
  static const _pad = EdgeInsets.fromLTRB(
    AppSpacing.md,
    AppSpacing.md,
    AppSpacing.md,
    0,
  );

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (layout == HomeLayout.list) {
            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: _pad,
              itemCount: 8,
              separatorBuilder:
                  (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, __) => const _CardSkeleton(height: 88),
            );
          }
          final cols = gridColumns(constraints.maxWidth);
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: _pad,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int c = 0; c < cols; c++) ...[
                  if (c > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      children: [
                        for (int r = 0; r < 5; r++) ...[
                          if (r > 0) const SizedBox(height: AppSpacing.sm),
                          _CardSkeleton(
                            height:
                                _gridHeights[(c * 2 + r) % _gridHeights.length],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A card outline with a title bar and two text lines.
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FractionallySizedBox(
            widthFactor: 0.6,
            child: SkeletonBox(height: 14),
          ),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: 10),
          SizedBox(height: AppSpacing.sm),
          FractionallySizedBox(
            widthFactor: 0.8,
            child: SkeletonBox(height: 10),
          ),
        ],
      ),
    );
  }
}
