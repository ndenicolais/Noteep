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
import '../../models/note_model.dart';

class NoteChecklistEditor extends StatelessWidget {
  const NoteChecklistEditor({
    super.key,
    required this.items,
    required this.textStyle,
    required this.onChanged,
  });

  final List<ChecklistItem> items;
  final TextStyle textStyle;
  final ValueChanged<List<ChecklistItem>> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Checkbox(
                value: item.isChecked,
                onChanged: (v) {
                  items[index] = item.copyWith(isChecked: v);
                  onChanged(List.from(items));
                },
              ),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: item.text)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: item.text.length),
                    ),
                  style: textStyle.copyWith(
                    decoration:
                        item.isChecked ? TextDecoration.lineThrough : null,
                    color:
                        item.isChecked
                            ? textStyle.color?.withAlpha(100)
                            : textStyle.color,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Elemento...',
                  ),
                  onChanged: (v) {
                    item.text = v;
                    onChanged(List.from(items));
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  items.removeAt(index);
                  onChanged(List.from(items));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
