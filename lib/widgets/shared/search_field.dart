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
import '../../l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/core_providers.dart';
import '../../theme/app_spacing.dart';

class SearchField extends ConsumerWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.provider,
    required this.hintText,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueStateProvider<String> provider;
  final String hintText;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(provider);

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      // Fixed-height field inside the app bar: cap the system text size so
      // the text isn't clipped (the field still grows to 1.5×).
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.5,
        child: TextField(
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                query.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        controller.clear();
                        ref.read(provider.notifier).set('');
                        onChanged?.call();
                      },
                      tooltip: context.l10n.commonClearSearch,
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          onChanged: (v) {
            ref.read(provider.notifier).set(v);
            onChanged?.call();
          },
        ),
      ),
    );
  }
}
