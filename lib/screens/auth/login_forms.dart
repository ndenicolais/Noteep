// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_spacing.dart';
import 'login_validators.dart';

/// "Accedi" tab: email + password, forgot-password link, submit.
class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;

  /// `null` while a request is in flight (disables the button).
  final VoidCallback? onSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EmailField(controller: emailCtrl),
          const SizedBox(height: 14),
          _PasswordField(
            controller: passCtrl,
            label: l10n.commonPassword,
            validator: (v) => validatePassword(l10n, v),
            onSubmitted: onSubmit,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
              ),
              child: Text(l10n.loginForgotPassword),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SubmitButton(label: l10n.loginSubmitSignIn, onPressed: onSubmit),
        ],
      ),
    );
  }
}

/// "Registrati" tab: email, password + confirmation, submit.
class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmPassCtrl,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmPassCtrl;

  /// `null` while a request is in flight (disables the button).
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EmailField(controller: emailCtrl),
          const SizedBox(height: 14),
          _PasswordField(
            controller: passCtrl,
            label: l10n.commonPassword,
            validator: (v) => validatePassword(l10n, v),
          ),
          const SizedBox(height: 14),
          _PasswordField(
            controller: confirmPassCtrl,
            label: l10n.loginConfirmPassword,
            validator:
                (v) => validatePasswordConfirmation(l10n, v, passCtrl.text),
            onSubmitted: onSubmit,
          ),
          const SizedBox(height: 20),
          _SubmitButton(label: l10n.loginSubmitRegister, onPressed: onSubmit),
        ],
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: l10n.commonEmail,
        prefixIcon: const Icon(Icons.email_outlined),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => validateEmail(l10n, v),
    );
  }
}

/// Obscured password field with a show/hide toggle. With [onSubmitted] it
/// is the last field of its form (keyboard "done" submits); otherwise the
/// keyboard moves to the next field.
class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final VoidCallback? onSubmitted;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final isLast = widget.onSubmitted != null;
    return TextFormField(
      controller: widget.controller,
      obscureText: !_visible,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: isLast ? (_) => widget.onSubmitted!() : null,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_visible ? Icons.visibility_off : Icons.visibility),
          tooltip:
              _visible
                  ? context.l10n.loginHidePassword
                  : context.l10n.loginShowPassword,
          onPressed: () => setState(() => _visible = !_visible),
        ),
      ),
      validator: widget.validator,
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontSize: AppFontSizes.lg)),
    );
  }
}
