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

/// [RefreshIndicator] that also works when [child] is not scrollable (empty
/// or error states): such a child is wrapped in an always-scrollable view
/// filling the available height, so it can still be pulled down.
///
/// Scrollable children must use [AlwaysScrollableScrollPhysics] themselves,
/// otherwise a list shorter than the screen can't be pulled.
class PullToRefresh extends StatelessWidget {
  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.childIsScrollable = false,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final bool childIsScrollable;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child:
          childIsScrollable
              ? child
              : LayoutBuilder(
                builder:
                    (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: child,
                      ),
                    ),
              ),
    );
  }
}
