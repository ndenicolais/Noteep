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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

// ─── Sections enum ────────────────────────────────────────────────────────────

enum DrawerSection {
  home,
  tasks,
  reminders,
  calendar,
  labels,
  archive,
  trash,
  settings,
}

// ─── Named route constants ────────────────────────────────────────────────────

class AppRoutes {
  static const tasks = '/tasks';
  static const reminders = '/reminders';
  static const calendar = '/calendar';
  static const labels = '/labels';
  static const archive = '/archive';
  static const trash = '/trash';
  static const settings = '/settings';
}

// ─── Shared navigation rule ───────────────────────────────────────────────────

/// The app-shell navigation rule, used by both [AppDrawer] and the
/// wide-layout navigation rail so the two can't drift out of sync: going to
/// Home pops back to the root screen; going anywhere else pushes a named
/// route, or replaces the current one if we're not already on Home (so
/// switching between sections doesn't pile up a deep navigation stack).
/// Pass `targetRoute: null` for Home.
void navigateToSection(
  BuildContext context, {
  required DrawerSection currentSection,
  required DrawerSection targetSection,
  required String? targetRoute,
}) {
  if (currentSection == targetSection) return;

  if (targetRoute == null) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    return;
  }
  if (currentSection == DrawerSection.home) {
    Navigator.pushNamed(context, targetRoute);
  } else {
    Navigator.pushReplacementNamed(context, targetRoute);
  }
}

// ─── Shared App Drawer ────────────────────────────────────────────────────────

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key, this.currentSection = DrawerSection.home});

  final DrawerSection currentSection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withAlpha(40),
                    backgroundImage:
                        user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                    child:
                        user?.photoURL == null
                            ? Icon(
                              Icons.person,
                              size: 26,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            )
                            : null,
                  ),
                  const SizedBox(height: 8),
                  if (user?.displayName != null &&
                      user!.displayName!.isNotEmpty)
                    Text(
                      user.displayName!,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (user?.email != null)
                    Text(
                      user!.email!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withAlpha(200),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.lightbulb_outline,
              label: 'Note',
              selected: currentSection == DrawerSection.home,
              onTap: () => _navigateTo(context, DrawerSection.home, null),
            ),
            _DrawerItem(
              icon: Icons.check_circle_outline,
              label: 'Task',
              selected: currentSection == DrawerSection.tasks,
              onTap:
                  () => _navigateTo(
                    context,
                    DrawerSection.tasks,
                    AppRoutes.tasks,
                  ),
            ),
            _DrawerItem(
              icon: Icons.notifications_outlined,
              label: 'Promemoria',
              selected: currentSection == DrawerSection.reminders,
              onTap:
                  () => _navigateTo(
                    context,
                    DrawerSection.reminders,
                    AppRoutes.reminders,
                  ),
            ),
            _DrawerItem(
              icon: Icons.calendar_today_outlined,
              label: 'Calendario',
              selected: currentSection == DrawerSection.calendar,
              onTap:
                  () => _navigateTo(
                    context,
                    DrawerSection.calendar,
                    AppRoutes.calendar,
                  ),
            ),
            _DrawerItem(
              icon: Icons.label_outline,
              label: 'Etichette',
              selected: currentSection == DrawerSection.labels,
              onTap:
                  () => _navigateTo(
                    context,
                    DrawerSection.labels,
                    AppRoutes.labels,
                  ),
            ),
            _DrawerItem(
              icon: Icons.archive_outlined,
              label: 'Archivio',
              selected: currentSection == DrawerSection.archive,
              onTap:
                  () => _navigateTo(
                    context,
                    DrawerSection.archive,
                    AppRoutes.archive,
                  ),
            ),
            _DrawerItem(
              icon: Icons.delete_outline,
              label: 'Cestino',
              selected: currentSection == DrawerSection.trash,
              onTap:
                  () => _navigateTo(
                    context,
                    DrawerSection.trash,
                    AppRoutes.trash,
                  ),
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Impostazioni',
              selected: currentSection == DrawerSection.settings,
              onTap:
                  () => _navigateTo(
                    context,
                    DrawerSection.settings,
                    AppRoutes.settings,
                  ),
            ),
            const Divider(),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Esci',
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authNotifierProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(
    BuildContext context,
    DrawerSection targetSection,
    String? targetRoute,
  ) {
    Navigator.pop(context); // close drawer
    navigateToSection(
      context,
      currentSection: currentSection,
      targetSection: targetSection,
      targetRoute: targetRoute,
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      onTap: onTap,
    );
  }
}
