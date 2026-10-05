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
import 'app_drawer.dart';

export 'app_drawer.dart' show DrawerSection, AppRoutes;

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
              const SizedBox(width: 32),
              Image.asset(
                'assets/images/app_logo_icon.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 4),
              Text(
                'Noteep',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
            ],
          ],
          const SizedBox(width: 32),
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
            padding: const EdgeInsets.only(left: 32),
            icon: const Icon(Icons.menu),
            onPressed: _toggleCollapse,
            tooltip: _collapsed ? 'Espandi menu' : 'Comprimi menu',
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
                tooltip: 'Apri menu',
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
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.lightbulb_outline),
          selectedIcon: Icon(Icons.lightbulb),
          label: Text('Note'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.check_circle_outline),
          selectedIcon: Icon(Icons.check_circle),
          label: Text('Task'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: Text('Calendario'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: Text('Promemoria'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.label_outline),
          selectedIcon: Icon(Icons.label),
          label: Text('Etichette'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.archive_outlined),
          selectedIcon: Icon(Icons.archive),
          label: Text('Archivio'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.delete_outline),
          selectedIcon: Icon(Icons.delete),
          label: Text('Cestino'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Impostazioni'),
        ),
      ],
    );
  }
}
