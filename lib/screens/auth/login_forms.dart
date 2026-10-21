// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:flutter/material.dart';
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
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EmailField(controller: emailCtrl),
          const SizedBox(height: 14),
          _PasswordField(
            controller: passCtrl,
            label: 'Password',
            validator: validatePassword,
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
              child: const Text('Password dimenticata?'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SubmitButton(label: 'Accedi', onPressed: onSubmit),
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
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EmailField(controller: emailCtrl),
          const SizedBox(height: 14),
          _PasswordField(
            controller: passCtrl,
            label: 'Password',
            validator: validatePassword,
          ),
          const SizedBox(height: 14),
          _PasswordField(
            controller: confirmPassCtrl,
            label: 'Conferma password',
            validator: (v) => validatePasswordConfirmation(v, passCtrl.text),
            onSubmitted: onSubmit,
          ),
          const SizedBox(height: 20),
          _SubmitButton(label: 'Crea account', onPressed: onSubmit),
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
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
      validator: validateEmail,
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
          tooltip: _visible ? 'Nascondi password' : 'Mostra password',
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
