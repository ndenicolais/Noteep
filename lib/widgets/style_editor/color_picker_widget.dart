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

import '../../theme/app_colors.dart';

class ColorPickerWidget extends StatelessWidget {
  const ColorPickerWidget({
    super.key,
    required this.current,
    required this.onPick,
    this.isDark = false,
  });

  final Color current;
  final ValueChanged<Color> onPick;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final presets =
        isDark ? AppColors.noteSwatchesDark : AppColors.noteSwatchesLight;
    final colorScheme = Theme.of(context).colorScheme;
    final unselectedBorder = colorScheme.outlineVariant;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...presets.map(
          (c) => GestureDetector(
            onTap: () => onPick(c),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: current == c ? colorScheme.primary : unselectedBorder,
                  width: current == c ? 3 : 1,
                ),
                boxShadow: [
                  if (current == c)
                    BoxShadow(color: c.withAlpha(102), blurRadius: 8),
                ],
              ),
            ),
          ),
        ),
        // Pulsante "Custom" che apre una griglia Material semplice
        GestureDetector(
          onTap: () => _showSimpleGrid(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: unselectedBorder),
              gradient: const SweepGradient(
                colors: [
                  Colors.red,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.purple,
                  Colors.red,
                ],
              ),
            ),
            child: Icon(Icons.add, size: 18, color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  void _showSimpleGrid(BuildContext context) {
    // Invece del package, usiamo i colori base di Flutter in una GridView
    final List<Color> materialColors = [...Colors.primaries, ...Colors.accents];

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Colori Material'),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: materialColors.length,
                itemBuilder: (_, i) {
                  final color = materialColors[i];
                  return GestureDetector(
                    onTap: () {
                      onPick(color);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              current == color
                                  ? Theme.of(ctx).colorScheme.onSurface
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Chiudi'),
              ),
            ],
          ),
    );
  }
}
