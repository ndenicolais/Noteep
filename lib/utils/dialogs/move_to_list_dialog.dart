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
import '../../providers/tasks_provider.dart';

/// Mostra un dialogo per spostare un task in un elenco diverso
///
/// [currentListId] - L'ID dell'elenco attualmente assegnato
/// [onListSelected] - Callback quando l'utente seleziona un nuovo elenco
void showMoveToListDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String? currentListId,
  required Function(String?) onListSelected,
}) {
  final lists = ref.read(taskListsProvider);
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Sposta in un elenco'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('Nessun elenco'),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: currentListId,
                    onChanged: (v) {
                      onListSelected(v);
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    onListSelected(null);
                    Navigator.pop(context);
                  },
                ),
                ...lists.map(
                  (l) => ListTile(
                    title: Text(l.name),
                    leading: Radio<String?>(
                      value: l.id,
                      groupValue: currentListId,
                      onChanged: (v) {
                        onListSelected(v);
                        Navigator.pop(context);
                      },
                    ),
                    onTap: () {
                      onListSelected(l.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}
