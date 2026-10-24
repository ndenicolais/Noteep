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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import '../providers/settings/ui_provider.dart';
import '../theme/app_font_sizes.dart';
import '../theme/app_spacing.dart';
import '../widgets/nav_scaffold.dart';
import '../widgets/shared/app_dialogs.dart';

class LabelsScreen extends ConsumerWidget {
  const LabelsScreen({super.key});

  Future<void> _showAddLabelDialog(BuildContext context, WidgetRef ref) async {
    final name = await showAppTextInputDialog(
      context,
      title: context.l10n.labelsNew,
      hintText: context.l10n.labelsNameHint,
      confirmLabel: context.l10n.tasksCreate,
      textCapitalization: TextCapitalization.sentences,
    );
    if (name != null) ref.read(customLabelsProvider.notifier).addLabel(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(allTagsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return NavScaffold(
      section: DrawerSection.labels,
      titleWidget: Text(context.l10n.navLabels),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLabelDialog(context, ref),
        tooltip: context.l10n.labelsNew,
        child: const Icon(Icons.add),
      ),
      body:
          tags.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.label_outline,
                      size: 64,
                      color: colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      context.l10n.labelsEmpty,
                      style: TextStyle(
                        color: colorScheme.outline,
                        fontSize: AppFontSizes.lg,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.labelsEmptyHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  ],
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: tags.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => _LabelTile(tag: tags[i]),
              ),
    );
  }
}

class _LabelTile extends ConsumerWidget {
  const _LabelTile({required this.tag});
  final String tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.label_outline),
      title: Text(tag),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showRenameDialog(context, ref),
            tooltip: context.l10n.labelsRename,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
            tooltip: context.l10n.commonDelete,
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
    final newName = await showAppTextInputDialog(
      context,
      title: context.l10n.labelsRenameTitle,
      hintText: context.l10n.labelsNameHint,
      confirmLabel: context.l10n.commonSave,
      initialValue: tag,
    );
    if (newName == null || newName == tag) return;
    ref.read(notesProvider.notifier).renameTag(tag, newName);
    ref.read(customLabelsProvider.notifier).renameLabel(tag, newName);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: context.l10n.labelsDeleteTitle,
      message: context.l10n.labelsDeleteConfirm(tag),
      confirmLabel: context.l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    ref.read(notesProvider.notifier).deleteTag(tag);
    ref.read(customLabelsProvider.notifier).deleteLabel(tag);
  }
}
