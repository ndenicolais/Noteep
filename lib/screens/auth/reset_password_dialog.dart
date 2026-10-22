// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'login_validators.dart';

/// Asks for the email to send the password-reset link to, prefilled with
/// [initialEmail]. Resolves to the trimmed email, or `null` if cancelled.
Future<String?> showResetPasswordDialog(
  BuildContext context, {
  String initialEmail = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _ResetPasswordDialog(initialEmail: initialEmail),
  );
}

class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  late final _emailCtrl = TextEditingController(text: widget.initialEmail);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _emailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.loginResetTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.commonEmail,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          validator: (v) => validateEmail(l10n, v),
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.loginResetSend)),
      ],
    );
  }
}
