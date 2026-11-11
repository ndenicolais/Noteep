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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings/ui_provider.dart';
import 'app_router.dart';

/// The named route of [section], or null for Notes (the root screen).
String? startSectionRoute(StartSection section) => switch (section) {
  StartSection.calendar => AppRoutes.calendar,
  StartSection.tasks => AppRoutes.tasks,
  StartSection.notes => null,
};

/// Opens the start section chosen in Settings on top of the root (Notes)
/// screen when the signed-in home first appears, without a transition, so
/// the app looks like it opened there. Back returns to Notes, as from any
/// other section.
///
/// Wrap it outside the notification and home-widget launch handlers: its
/// post-frame callback then runs first, and whatever they open lands above
/// the start section.
class StartSectionLauncher extends ConsumerStatefulWidget {
  const StartSectionLauncher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<StartSectionLauncher> createState() =>
      _StartSectionLauncherState();
}

class _StartSectionLauncherState extends ConsumerState<StartSectionLauncher> {
  @override
  void initState() {
    super.initState();
    final route = startSectionRoute(ref.read(startSectionProvider));
    if (route == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushNamed(route, arguments: AppRouter.noTransition);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
