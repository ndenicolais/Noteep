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

/// Cross-fades between screen states (loading → list → empty/error).
///
/// Give each state's root widget a distinct [Key]: only a key change
/// triggers the fade, so data updates inside the same state don't animate.
/// Children fill the available space (unlike [AnimatedSwitcher]'s default
/// centered stack), and the fade is skipped when the platform asks to
/// reduce motion.
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
            children: [...previous, if (current != null) current],
          ),
      child: child,
    );
  }
}
