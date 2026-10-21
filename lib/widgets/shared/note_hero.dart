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
import '../../theme/app_radius.dart';

/// Hero tag linking a `NoteCard` to its open editor.
///
/// Equality is by note id only; [color] is the background of the side that
/// created the tag (card or editor), read back by [NoteHero]'s flight to
/// blend between the two.
class NoteHeroTag {
  const NoteHeroTag(this.noteId, this.color);

  final String noteId;
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is NoteHeroTag && other.noteId == noteId;

  @override
  int get hashCode => noteId.hashCode;
}

/// Lightweight "container transform" between a note card and the editor:
/// the card's colored shape grows into the page (corners squaring off,
/// color blending) while the editor content fades in; reversed on pop.
///
/// Disabled when the platform asks to reduce motion.
class NoteHero extends StatelessWidget {
  const NoteHero({
    super.key,
    required this.noteId,
    required this.color,
    required this.isPage,
    required this.child,
  });

  final String noteId;
  final Color color;

  /// `true` on the editor side, `false` on the card side.
  final bool isPage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: !MediaQuery.disableAnimationsOf(context),
      child: Hero(
        tag: NoteHeroTag(noteId, color),
        flightShuttleBuilder: _shuttle,
        child: child,
      ),
    );
  }

  static Widget _shuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    final push = direction == HeroFlightDirection.push;
    final cardCtx = push ? fromContext : toContext;
    final pageCtx = push ? toContext : fromContext;
    final cardColor = ((cardCtx.widget as Hero).tag as NoteHeroTag).color;
    final pageColor = ((pageCtx.widget as Hero).tag as NoteHeroTag).color;
    final pageChild = (pageCtx.widget as Hero).child;
    final pageSize = (pageCtx.findRenderObject() as RenderBox?)?.size;
    // Same curve both ways: the flight animation runs 0→1 on push and
    // 1→0 on pop, so 0 is always "card" and 1 always "page".
    final content = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(animation.value);
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md * (1 - t)),
          child: ColoredBox(
            color: Color.lerp(cardColor, pageColor, t)!,
            child: child,
          ),
        );
      },
      // The page is laid out at its final size and clipped, so the editor
      // never re-lays out (and overflows) at the intermediate sizes.
      child: FadeTransition(
        opacity: content,
        child:
            pageSize == null
                ? const SizedBox.shrink()
                : OverflowBox(
                  alignment: Alignment.topCenter,
                  minWidth: pageSize.width,
                  maxWidth: pageSize.width,
                  minHeight: pageSize.height,
                  maxHeight: pageSize.height,
                  child: pageChild,
                ),
      ),
    );
  }
}
