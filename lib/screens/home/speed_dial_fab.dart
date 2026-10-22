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
import '../../l10n/l10n.dart';
import '../../theme/app_spacing.dart';

class SpeedDialFab extends StatefulWidget {
  const SpeedDialFab({
    super.key,
    required this.onNoteTap,
    required this.onChecklistTap,
    required this.onTaskTap,
    this.onAudioNoteTap,
    this.onTemplateTap,
  });

  final VoidCallback onNoteTap;
  final VoidCallback onChecklistTap;
  final VoidCallback onTaskTap;
  final VoidCallback? onAudioNoteTap;
  final VoidCallback? onTemplateTap;

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  final GlobalKey _anchorKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() => _open ? _close() : _openMenu();

  void _openMenu() {
    setState(() => _open = true);
    _ctrl.forward();
    _overlayEntry = OverlayEntry(builder: (_) => _buildOverlay());
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _close() {
    if (!_open) return;
    _ctrl.reverse().whenComplete(_removeOverlay);
    setState(() => _open = false);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  List<({IconData icon, String label, VoidCallback onTap})> _items() => [
    (
      icon: Icons.task_alt,
      label: context.l10n.homeFabTask,
      onTap: widget.onTaskTap,
    ),
    (
      icon: Icons.checklist,
      label: context.l10n.homeFabChecklist,
      onTap: widget.onChecklistTap,
    ),
    (
      icon: Icons.notes,
      label: context.l10n.homeFabNote,
      onTap: widget.onNoteTap,
    ),
    if (widget.onAudioNoteTap != null)
      (
        icon: Icons.mic,
        label: context.l10n.homeFabAudio,
        onTap: widget.onAudioNoteTap!,
      ),
    if (widget.onTemplateTap != null)
      (
        icon: Icons.auto_awesome_outlined,
        label: context.l10n.homeFabTemplate,
        onTap: widget.onTemplateTap!,
      ),
  ];

  Widget _mainButton() {
    return Semantics(
      expanded: _open,
      label:
          _open ? context.l10n.homeFabCloseMenu : context.l10n.homeFabOpenMenu,
      child: FloatingActionButton(
        heroTag: 'fab_main',
        // A single tap opens the menu — the standard speed-dial gesture — so
        // "Task"/"Lista"/"Audio"/"Modello" are actually discoverable instead
        // of hidden behind a long-press. Quick blank notes are one tap away
        // via the "Nota" menu item.
        onPressed: _toggle,
        tooltip:
            _open
                ? context.l10n.homeFabCloseTooltip
                : context.l10n.homeFabOpenTooltip,
        child: AnimatedRotation(
          turns: _open ? 0.125 : 0.0,
          duration: const Duration(milliseconds: 220),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    final anchorBox =
        _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final anchorTopLeft = anchorBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final anchorSize = anchorBox?.size ?? const Size(56, 56);
    final screenSize = MediaQuery.of(context).size;
    final bottom = screenSize.height - anchorTopLeft.dy - anchorSize.height;
    final right = screenSize.width - anchorTopLeft.dx - anchorSize.width;
    final items = _items();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
                child: Container(
                  color: Colors.black.withAlpha(
                    (0.4 * _ctrl.value * 255).round(),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: bottom,
              right: right,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ...items.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final delay = i * 0.15;
                    final t = ((_ctrl.value - delay) / (1.0 - delay)).clamp(
                      0.0,
                      1.0,
                    );
                    final curve = Curves.easeOut.transform(t);
                    return Opacity(
                      opacity: curve,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - curve)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: FloatingActionButton.extended(
                            heroTag: 'fab_item_$i',
                            onPressed: () {
                              _close();
                              item.onTap();
                            },
                            icon: Icon(item.icon),
                            label: Text(item.label),
                          ),
                        ),
                      ),
                    );
                  }),
                  _mainButton(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // While open, the interactive copy lives in the overlay (built in
    // _buildOverlay); this anchor just reserves the FAB's slot/position so
    // the overlay can align to it, and stays invisible to avoid a double
    // button underneath.
    return KeyedSubtree(
      key: _anchorKey,
      child: Visibility(
        visible: !_open,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: _mainButton(),
      ),
    );
  }
}
