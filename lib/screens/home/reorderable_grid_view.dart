// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../models/note_model.dart';
import '../../widgets/note_card.dart';
import 'home_layout_utils.dart';

class ReorderableGridView extends StatefulWidget {
  const ReorderableGridView({
    super.key,
    required this.notes,
    required this.onReorder,
  });

  final List<NoteModel> notes;
  final void Function(int from, int to) onReorder;

  @override
  State<ReorderableGridView> createState() => _ReorderableGridViewState();
}

class _ReorderableGridViewState extends State<ReorderableGridView> {
  int? _dragging;
  int? _hovered;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final cols = gridColumns(constraints.maxWidth);
        const double spacing = 8;
        const double pad = 12;
        final itemWidth =
            (constraints.maxWidth - pad * 2 - spacing * (cols - 1)) / cols;
        final rowCount =
            widget.notes.isEmpty ? 0 : ((widget.notes.length - 1) ~/ cols) + 1;
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(ctx).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((_, row) {
                    final start = row * cols;
                    final end = (start + cols).clamp(0, widget.notes.length);
                    final filled = end - start;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: row < rowCount - 1 ? spacing : 0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = start; i < end; i++) ...[
                            if (i > start) SizedBox(width: spacing),
                            Expanded(child: _buildItem(ctx, i, itemWidth)),
                          ],
                          // Fill remaining cells in last partial row
                          for (int k = filled; k < cols; k++) ...[
                            SizedBox(width: spacing),
                            const Expanded(child: SizedBox()),
                          ],
                        ],
                      ),
                    );
                  }, childCount: rowCount),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(BuildContext ctx, int i, double itemWidth) {
    final note = widget.notes[i];
    final isDragging = _dragging == i;
    final isTarget = _hovered == i && !isDragging;
    return DragTarget<int>(
      key: ValueKey(note.id),
      onWillAcceptWithDetails: (d) => d.data != i,
      onAcceptWithDetails: (d) {
        widget.onReorder(d.data, i);
        setState(() {
          _dragging = null;
          _hovered = null;
        });
      },
      onMove: (_) {
        if (_hovered != i) setState(() => _hovered = i);
      },
      onLeave: (_) {
        if (_hovered == i) setState(() => _hovered = null);
      },
      builder: (_, __, ___) {
        return Draggable<int>(
          data: i,
          onDragStarted: () => setState(() => _dragging = i),
          onDragEnd:
              (_) => setState(() {
                _dragging = null;
                _hovered = null;
              }),
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: itemWidth, maxHeight: 350),
              child: NoteCard(note: note),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: NoteCard(note: note),
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration:
                isTarget
                    ? BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(ctx).colorScheme.primary,
                        width: 2,
                      ),
                    )
                    : const BoxDecoration(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: NoteCard(note: note),
            ),
          ),
        );
      },
    );
  }
}
