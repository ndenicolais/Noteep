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

/// One side of a [SwipeActions] row.
class SwipeAction {
  const SwipeAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTriggered,
    this.removesItem = true,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTriggered;

  /// Whether [onTriggered] removes the item from the list it's shown in
  /// (trash, archive). If false (e.g. completing a task that stays visible)
  /// the row snaps back instead of being dismissed, since a dismissed
  /// [Dismissible] must leave the widget tree.
  final bool removesItem;
}

/// Swipe right for [start], swipe left for [end]. Actions run as soon as
/// the swipe completes; undo is up to [SwipeAction.onTriggered] (see
/// `notifyWithUndo`).
class SwipeActions extends StatelessWidget {
  const SwipeActions({
    super.key,
    required this.id,
    required this.start,
    required this.end,
    required this.child,
  });

  /// Stable id of the swiped item, used for the [Dismissible] key.
  final String id;
  final SwipeAction start;
  final SwipeAction end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('swipe-$id'),
      background: DismissBackground(
        alignment: Alignment.centerLeft,
        color: start.color,
        icon: start.icon,
        label: start.label,
      ),
      secondaryBackground: DismissBackground(
        alignment: Alignment.centerRight,
        color: end.color,
        icon: end.icon,
        label: end.label,
      ),
      confirmDismiss: (direction) async {
        final action = direction == DismissDirection.startToEnd ? start : end;
        action.onTriggered();
        return action.removesItem;
      },
      child: child,
    );
  }
}

/// Colored background with icon + label revealed under a swiped row.
class DismissBackground extends StatelessWidget {
  const DismissBackground({
    super.key,
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
