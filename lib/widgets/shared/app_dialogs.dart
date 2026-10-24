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
import '../../l10n/l10n.dart';

/// [showModalBottomSheet] whose content stays clear of the system
/// navigation bar: with edge-to-edge (enforced from Android 15) the sheet
/// is drawn down to the screen edge, so its content gets a bottom
/// [SafeArea] while the sheet background still reaches the edge. Shape
/// comes from `bottomSheetTheme` in `AppTheme`.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    builder: (ctx) => SafeArea(top: false, child: builder(ctx)),
  );
}

/// Shared "title + single text field + Annulla/confirm" dialog.
///
/// Resolves to the trimmed text when confirmed (button or keyboard submit)
/// and non-empty; `null` when cancelled, dismissed or left empty. The field
/// starts with [initialValue] (e.g. the current name when renaming).
/// [obscureText] hides the input and returns it untrimmed (passwords).
Future<String?> showAppTextInputDialog(
  BuildContext context, {
  required String title,
  required String hintText,
  required String confirmLabel,
  String initialValue = '',
  TextCapitalization textCapitalization = TextCapitalization.none,
  bool obscureText = false,
}) {
  return showDialog<String>(
    context: context,
    builder:
        (_) => _TextInputDialog(
          title: title,
          hintText: hintText,
          confirmLabel: confirmLabel,
          initialValue: initialValue,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
        ),
  );
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.hintText,
    required this.confirmLabel,
    required this.initialValue,
    required this.textCapitalization,
    required this.obscureText,
  });

  final String title;
  final String hintText;
  final String confirmLabel;
  final String initialValue;
  final TextCapitalization textCapitalization;
  final bool obscureText;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text =
        widget.obscureText ? _controller.text : _controller.text.trim();
    Navigator.pop(context, text.isEmpty ? null : text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: widget.textCapitalization,
        obscureText: widget.obscureText,
        decoration: InputDecoration(hintText: widget.hintText),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}

/// Shared "title + message + Annulla/confirm" dialog.
///
/// Resolves to `true` only when the user taps the confirm button; dismissing
/// the dialog (cancel, barrier tap, back) resolves to `false`. Shape comes
/// from `dialogTheme` in `AppTheme`. [destructive] paints the confirm button
/// with the theme's error colors.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel ?? ctx.l10n.commonCancel),
          ),
          if (destructive)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmLabel),
            )
          else
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(confirmLabel),
            ),
        ],
      );
    },
  );
  return confirmed == true;
}

/// Shared "title + message + OK" dialog for information that needs no
/// decision (e.g. a feature not available yet).
Future<void> showAppMessageDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? okLabel,
}) {
  return showDialog<void>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(okLabel ?? ctx.l10n.commonOk),
            ),
          ],
        ),
  );
}
