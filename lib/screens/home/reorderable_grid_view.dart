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
import '../../l10n/l10n.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/note_model.dart';
import '../../providers/notes_provider.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/note_card.dart';
import 'home_layout_utils.dart';

/// Masonry grid of the notes in [noteIds], with drag & drop reordering.
/// Each card watches its own note (`noteByIdProvider`), so editing one note
/// rebuilds only its card while [noteIds] stays the same.
class ReorderableGridView extends StatefulWidget {
  const ReorderableGridView({
    super.key,
    required this.noteIds,
    required this.onReorder,
  });

  final List<String> noteIds;
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
        const double spacing = AppSpacing.sm;
        const double pad = AppSpacing.md;
        final itemWidth =
            (constraints.maxWidth - pad * 2 - spacing * (cols - 1)) / cols;
        final count = widget.noteIds.length;
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(ctx).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Masonry: independent lazy columns, each card at its natural
              // height. Note i goes to column i % cols, so reading order and
              // the global indices used by drag & drop stay row-major.
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  pad - spacing / 2,
                  pad,
                  pad - spacing / 2,
                  80,
                ),
                sliver: SliverCrossAxisGroup(
                  slivers: [
                    for (int col = 0; col < cols; col++)
                      SliverCrossAxisExpanded(
                        flex: 1,
                        sliver: SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: spacing / 2,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, row) => Padding(
                                padding: const EdgeInsets.only(bottom: spacing),
                                child: _buildItem(
                                  ctx,
                                  row * cols + col,
                                  itemWidth,
                                ),
                              ),
                              childCount: masonryColumnLength(count, cols, col),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(BuildContext ctx, int i, double itemWidth) {
    final id = widget.noteIds[i];
    final isDragging = _dragging == i;
    final isTarget = _hovered == i && !isDragging;
    return DragTarget<int>(
      key: ValueKey(id),
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
      builder:
          (_, __, ___) => Consumer(
            builder: (_, ref, _) {
              final note = ref.watch(noteByIdProvider(id));
              if (note == null) return const SizedBox.shrink();
              return _buildDraggable(ctx, i, itemWidth, note, isTarget);
            },
          ),
    );
  }

  Widget _buildDraggable(
    BuildContext ctx,
    int i,
    double itemWidth,
    NoteModel note,
    bool isTarget,
  ) {
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
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(width: itemWidth, child: NoteCard(note: note)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: NoteCard(note: note)),
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
        child: NoteCard(
          note: note,
          // Screen-reader alternative to drag & drop, same indices.
          extraSemanticsActions: {
            if (i > 0)
              CustomSemanticsAction(label: ctx.l10n.commonMoveEarlier):
                  () => widget.onReorder(i, i - 1),
            if (i < widget.noteIds.length - 1)
              CustomSemanticsAction(label: ctx.l10n.commonMoveLater):
                  () => widget.onReorder(i, i + 1),
          },
        ),
      ),
    );
  }
}
