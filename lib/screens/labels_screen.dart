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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_provider.dart';
import '../providers/settings/ui_provider.dart';
import '../widgets/nav_scaffold.dart';

class LabelsScreen extends ConsumerWidget {
  const LabelsScreen({super.key});

  void _showAddLabelDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Nuova etichetta'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Nome etichetta'),
              textCapitalization: TextCapitalization.sentences,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              FilledButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    ref.read(customLabelsProvider.notifier).addLabel(name);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Crea'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(allTagsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return NavScaffold(
      section: DrawerSection.labels,
      titleWidget: const Text('Etichette'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLabelDialog(context, ref),
        tooltip: 'Nuova etichetta',
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
                    const SizedBox(height: 16),
                    Text(
                      'Nessuna etichetta',
                      style: TextStyle(
                        color: colorScheme.outline,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea una nuova etichetta o aggiungila da una nota.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  ],
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
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
            tooltip: 'Rinomina',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
            tooltip: 'Elimina',
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: tag);
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Rinomina etichetta'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Nome etichetta'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              FilledButton(
                onPressed: () {
                  final newName = controller.text.trim();
                  if (newName.isNotEmpty && newName != tag) {
                    ref.read(notesProvider.notifier).renameTag(tag, newName);
                    ref
                        .read(customLabelsProvider.notifier)
                        .renameLabel(tag, newName);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Salva'),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Elimina etichetta'),
            content: Text(
              'L\'etichetta "$tag" verrà rimossa da tutte le note.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  ref.read(notesProvider.notifier).deleteTag(tag);
                  ref.read(customLabelsProvider.notifier).deleteLabel(tag);
                  Navigator.pop(ctx);
                },
                child: const Text('Elimina'),
              ),
            ],
          ),
    );
  }
}
