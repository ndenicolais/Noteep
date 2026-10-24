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
import '../l10n/l10n.dart';
import 'package:intl/intl.dart';
import '../theme/app_font_sizes.dart';
import '../theme/app_spacing.dart';

/// Banner shown at the top of the note/task/event editor when a reminder is
/// set: tap to change it, × to remove it.
class ReminderBanner extends StatelessWidget {
  const ReminderBanner({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onRemove,
  });

  final DateTime reminder;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: colorScheme.primaryContainer.withAlpha(180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 6,
        ),
        child: Row(
          children: [
            Icon(Icons.alarm, size: 16, color: colorScheme.onPrimaryContainer),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                DateFormat('dd MMM yyyy, HH:mm').format(reminder),
                style: TextStyle(
                  fontSize: AppFontSizes.sm,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Semantics(
              button: true,
              label: context.l10n.commonRemoveReminder,
              excludeSemantics: true,
              child: GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
