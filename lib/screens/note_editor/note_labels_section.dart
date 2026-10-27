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

/// The note's labels as chips; tapping one opens the label picker.
class NoteLabelsSection extends StatelessWidget {
  const NoteLabelsSection({super.key, required this.tags, required this.onTap});

  final List<String> tags;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final tag in tags)
            ActionChip(
              avatar: const Icon(Icons.label_outline, size: 16),
              label: Text(tag, maxLines: 1, overflow: TextOverflow.ellipsis),
              onPressed: onTap,
            ),
        ],
      ),
    );
  }
}
