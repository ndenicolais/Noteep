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
import '../../theme/app_font_sizes.dart';

/// Non-interactive label chip in the secondary container colors: note
/// tags on cards ([dense]) and technology badges in the Info screen.
class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key, this.dense = false});

  final String label;

  /// Smaller text and no padding, for chips inside a card.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: dense ? AppFontSizes.xs : AppFontSizes.sm,
          color: cs.onSecondaryContainer,
        ),
      ),
      backgroundColor: cs.secondaryContainer,
      side: BorderSide.none,
      padding: dense ? EdgeInsets.zero : null,
      materialTapTargetSize:
          dense
              ? MaterialTapTargetSize.shrinkWrap
              : MaterialTapTargetSize.padded,
    );
  }
}
