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
import '../l10n/l10n.dart';
import '../providers/settings/ui_provider.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class SortSheet extends StatelessWidget {
  const SortSheet({super.key, required this.current, required this.onChanged});
  final SortOrder current;
  final ValueChanged<SortOrder> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            l10n.sortTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.sortCreatedDate,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SortTile(
            icon: Icons.arrow_downward,
            label: l10n.sortNewestFirst,
            value: SortOrder.createdNewest,
            current: current,
            onTap: onChanged,
          ),
          SortTile(
            icon: Icons.arrow_upward,
            label: l10n.sortOldestFirst,
            value: SortOrder.createdOldest,
            current: current,
            onTap: onChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.sortModifiedDate,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SortTile(
            icon: Icons.arrow_downward,
            label: l10n.sortNewestFirst,
            value: SortOrder.modifiedNewest,
            current: current,
            onTap: onChanged,
          ),
          SortTile(
            icon: Icons.arrow_upward,
            label: l10n.sortOldestFirst,
            value: SortOrder.modifiedOldest,
            current: current,
            onTap: onChanged,
          ),
        ],
      ),
    );
  }
}

class SortTile extends StatelessWidget {
  const SortTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final SortOrder value;
  final SortOrder current;
  final ValueChanged<SortOrder> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = current == value;
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(label),
      trailing:
          selected
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      selected: selected,
      onTap: () => onTap(value),
    );
  }
}
