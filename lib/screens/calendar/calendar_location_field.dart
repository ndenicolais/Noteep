// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../utils/place_search_service.dart';

/// Event location field with suggestions while typing: the locations of
/// other events ([history], offline, shown at once) followed by a debounced
/// OpenStreetMap search ([PlaceSearchService]). The text stays free: a
/// suggestion only fills it in.
class CalendarLocationField extends StatefulWidget {
  const CalendarLocationField({
    super.key,
    required this.controller,
    required this.history,
  });

  final TextEditingController controller;
  final List<String> history;

  @override
  State<CalendarLocationField> createState() => _CalendarLocationFieldState();
}

class _CalendarLocationFieldState extends State<CalendarLocationField> {
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;
  Timer? _debounce;
  List<String> _live = const [];
  List<String> _options = const [];

  /// True while [_select] writes the chosen text, so the controller listener
  /// does not reopen the list it just closed.
  bool _selecting = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() =>
      _focusNode.hasFocus ? _updateOverlay() : _removeOverlay();

  void _onTextChanged() {
    if (_selecting) return;
    _live = const [];
    _updateOverlay();
    _debounce?.cancel();
    final text = widget.controller.text;
    final language = Localizations.localeOf(context).languageCode;
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await PlaceSearchService.search(text, language);
      // A newer text started its own search: drop these results.
      if (!mounted || widget.controller.text != text) return;
      _live = results;
      _updateOverlay();
    });
  }

  List<String> _computeOptions() {
    final q = widget.controller.text.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final options =
        [
          for (final h in widget.history)
            if (h.toLowerCase().contains(q) && h.toLowerCase() != q) h,
        ].take(3).toList();
    for (final s in _live) {
      if (!options.contains(s)) options.add(s);
    }
    return options;
  }

  void _updateOverlay() {
    _options = _computeOptions();
    if (!_focusNode.hasFocus || _options.isEmpty) {
      _removeOverlay();
      return;
    }
    if (_overlay == null) {
      _overlay = _buildOverlay();
      Overlay.of(context).insert(_overlay!);
    } else {
      _overlay!.markNeedsBuild();
    }
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _select(String option) {
    _debounce?.cancel();
    _selecting = true;
    widget.controller.value = TextEditingValue(
      text: option,
      selection: TextSelection.collapsed(offset: option.length),
    );
    _selecting = false;
    _removeOverlay();
    _focusNode.unfocus();
  }

  OverlayEntry _buildOverlay() {
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;
    return OverlayEntry(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 4),
            // The list lives in its own overlay: without this region a tap
            // on it counts as outside the field, which unfocuses it and
            // closes the list before the tap lands.
            child: TextFieldTapRegion(
              child: Material(
                elevation: 4,
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _options.length,
                    itemBuilder: (context, i) {
                      final option = _options[i];
                      final isLive = _live.contains(option);
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          isLive ? Icons.place_outlined : Icons.history,
                          size: 18,
                          color: isLive ? cs.primary : null,
                        ),
                        title: Text(
                          option,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _select(option),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        textCapitalization: TextCapitalization.words,
        onEditingComplete: () {
          _removeOverlay();
          _focusNode.unfocus();
        },
        decoration: InputDecoration(
          icon: const Icon(Icons.location_on_outlined),
          hintText: context.l10n.calendarLocationHint,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
