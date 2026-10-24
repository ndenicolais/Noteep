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

/// Cross-fades between screen states (loading → list → empty/error).
///
/// Give each state's root widget a distinct [Key]: only a key change
/// triggers the fade, so data updates inside the same state don't animate.
/// Children fill the available space (unlike [AnimatedSwitcher]'s default
/// centered stack), and the fade is skipped when the platform asks to
/// reduce motion. Heroes in the outgoing child are disabled.
class FadeSwitcher extends StatelessWidget {
  const FadeSwitcher({super.key, required this.child});

  final Widget child;

  static const duration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration:
          MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration,
      layoutBuilder:
          (current, previous) => Stack(
            fit: StackFit.expand,
            children: [
              // Outgoing children may hold heroes with the same tags as the
              // incoming one (e.g. note cards when switching grid/list).
              // Every child gets the same keyed wrapper, so one that turns
              // from incoming to outgoing keeps its state (scroll position).
              for (final p in previous)
                HeroMode(key: p.key, enabled: false, child: p),
              if (current != null)
                HeroMode(key: current.key, enabled: true, child: current),
            ],
          ),
      child: child,
    );
  }
}
