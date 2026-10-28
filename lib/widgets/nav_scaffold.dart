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
import '../l10n/l10n.dart';
import '../core/routing/app_router.dart';
import '../theme/app_spacing.dart';
import 'app_drawer.dart';

export '../core/routing/app_router.dart' show AppRoutes;
export 'app_drawer.dart' show DrawerSection;

/// Responsive scaffold.
/// - Wide (≥700 px): NavigationRail on left, collapsible via hamburger button.
/// - Mobile (<700 px): standard Drawer opened by hamburger button.
///
/// The AppBar is always: [☰ hamburger] [logo icon + "Noteep"] [titleWidget?] [appBarActions]
class NavScaffold extends StatefulWidget {
  const NavScaffold({
    super.key,
    required this.section,
    required this.body,

    /// Search field (HomeScreen) or section title Text (other screens).
    this.titleWidget,
    this.appBarActions = const [],
    this.floatingActionButton,
  });

  final DrawerSection section;
  final Widget body;
  final Widget? titleWidget;
  final List<Widget> appBarActions;
  final Widget? floatingActionButton;

  static const double _wideBreakpoint = 700;

  @override
  State<NavScaffold> createState() => _NavScaffoldState();
}

class _NavScaffoldState extends State<NavScaffold> {
  bool _collapsed = false;

  void _toggleCollapse() => setState(() => _collapsed = !_collapsed);

  AppBar _buildAppBar({required Widget hamburger, required bool isWide}) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 56,
      leading: hamburger,
      titleSpacing: 8,
      title: Row(
        children: [
          if (isWide) ...[
            if (widget.section == DrawerSection.home ||
                widget.section == DrawerSection.tasks ||
                widget.section == DrawerSection.calendar) ...[
              const SizedBox(width: AppSpacing.xxl),
              Image.asset('assets/images/app_logo.png', width: 24, height: 24),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Noteep',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: AppSpacing.lg),
            ],
          ],
          const SizedBox(width: AppSpacing.xxl),
          if (widget.titleWidget != null) Flexible(child: widget.titleWidget!),
        ],
      ),
      actions: widget.appBarActions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.sizeOf(context).width >= NavScaffold._wideBreakpoint;

    if (isWide) {
      return Scaffold(
        appBar: _buildAppBar(
          hamburger: IconButton(
            padding: const EdgeInsets.only(left: AppSpacing.xxl),
            icon: const Icon(Icons.menu),
            onPressed: _toggleCollapse,
            tooltip:
                _collapsed
                    ? context.l10n.navExpandMenu
                    : context.l10n.navCollapseMenu,
          ),
          isWide: true,
        ),
        body: Row(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: _AppNavRail(
                currentSection: widget.section,
                collapsed: _collapsed,
              ),
            ),
            Expanded(child: widget.body),
          ],
        ),
        floatingActionButton: widget.floatingActionButton,
      );
    }

    // Mobile: drawer
    return Scaffold(
      appBar: _buildAppBar(
        hamburger: Builder(
          builder:
              (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                tooltip: ctx.l10n.navOpenMenu,
              ),
        ),
        isWide: false,
      ),
      drawer: AppDrawer(currentSection: widget.section),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

// ─── Navigation Rail ─────────────────────────────────────────────────────────

class _AppNavRail extends StatelessWidget {
  const _AppNavRail({required this.currentSection, required this.collapsed});

  final DrawerSection currentSection;
  final bool collapsed;

  int get _selectedIndex {
    switch (currentSection) {
      case DrawerSection.home:
        return 0;
      case DrawerSection.tasks:
        return 1;
      case DrawerSection.calendar:
        return 2;
      case DrawerSection.reminders:
        return 3;
      case DrawerSection.labels:
        return 4;
      case DrawerSection.archive:
        return 5;
      case DrawerSection.trash:
        return 6;
      case DrawerSection.settings:
        return 7;
    }
  }

  // Order must match the NavigationRailDestination list below.
  static const _railSections = [
    DrawerSection.home,
    DrawerSection.tasks,
    DrawerSection.calendar,
    DrawerSection.reminders,
    DrawerSection.labels,
    DrawerSection.archive,
    DrawerSection.trash,
    DrawerSection.settings,
  ];
  static const _railRoutes = <String?>[
    null, // 0: home
    AppRoutes.tasks,
    AppRoutes.calendar,
    AppRoutes.reminders,
    AppRoutes.labels,
    AppRoutes.archive,
    AppRoutes.trash,
    AppRoutes.settings,
  ];

  void _navigate(BuildContext context, int index) {
    navigateToSection(
      context,
      currentSection: currentSection,
      targetSection: _railSections[index],
      targetRoute: _railRoutes[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => _navigate(context, i),
      labelType:
          collapsed
              ? NavigationRailLabelType.none
              : NavigationRailLabelType.all,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.lightbulb_outline),
          selectedIcon: const Icon(Icons.lightbulb),
          label: Text(context.l10n.navNotes),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.check_circle_outline),
          selectedIcon: const Icon(Icons.check_circle),
          label: Text(context.l10n.navTasks),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.calendar_today_outlined),
          selectedIcon: const Icon(Icons.calendar_today),
          label: Text(context.l10n.navCalendar),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.notifications_outlined),
          selectedIcon: const Icon(Icons.notifications),
          label: Text(context.l10n.navReminders),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.label_outline),
          selectedIcon: const Icon(Icons.label),
          label: Text(context.l10n.navLabels),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.archive_outlined),
          selectedIcon: const Icon(Icons.archive),
          label: Text(context.l10n.navArchive),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.delete_outline),
          selectedIcon: const Icon(Icons.delete),
          label: Text(context.l10n.navTrash),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(context.l10n.navSettings),
        ),
      ],
    );
  }
}
