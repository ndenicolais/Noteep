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
import '../../theme/app_spacing.dart';
import '../../utils/link_utils.dart';

/// Asks for a link's text and URL. Resolves to the Markdown link
/// (`[text](url)`) to insert, or `null` when cancelled. [initialText]
/// pre-fills the text field, e.g. with the current selection.
Future<String?> showInsertLinkDialog(
  BuildContext context, {
  String initialText = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _InsertLinkDialog(initialText: initialText),
  );
}

class _InsertLinkDialog extends StatefulWidget {
  const _InsertLinkDialog({required this.initialText});

  final String initialText;

  @override
  State<_InsertLinkDialog> createState() => _InsertLinkDialogState();
}

class _InsertLinkDialogState extends State<_InsertLinkDialog> {
  late final _textController = TextEditingController(text: widget.initialText);
  final _urlController = TextEditingController();
  String? _urlError;

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    final url = normalizeUrl(_urlController.text);
    if (url == null) {
      setState(() => _urlError = 'Inserisci un indirizzo valido');
      return;
    }
    Navigator.pop(context, buildMarkdownLink(_textController.text, url));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Inserisci link'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            autofocus: widget.initialText.isEmpty,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Testo (facoltativo)'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _urlController,
            autofocus: widget.initialText.isNotEmpty,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Indirizzo',
              hintText: 'https://...',
              errorText: _urlError,
            ),
            onChanged: (_) {
              if (_urlError != null) setState(() => _urlError = null);
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        TextButton(onPressed: _submit, child: const Text('Inserisci')),
      ],
    );
  }
}
