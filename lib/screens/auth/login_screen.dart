// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regConfirmPassCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmPassCtrl.dispose();
    super.dispose();
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  Future<void> _loginWithEmail() async {
    if (!_loginFormKey.currentState!.validate()) return;
    await ref
        .read(authNotifierProvider.notifier)
        .signInWithEmail(_loginEmailCtrl.text.trim(), _loginPassCtrl.text);
  }

  Future<void> _registerWithEmail() async {
    if (!_registerFormKey.currentState!.validate()) return;
    await ref
        .read(authNotifierProvider.notifier)
        .registerWithEmail(_regEmailCtrl.text.trim(), _regPassCtrl.text);
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  Future<void> _showResetPasswordDialog() async {
    final emailCtrl = TextEditingController(text: _loginEmailCtrl.text);
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Reimposta password'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: _validateEmail,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);

                  await ref
                      .read(authNotifierProvider.notifier)
                      .sendPasswordResetEmail(emailCtrl.text.trim());

                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Email di reimpostazione inviata.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('Invia'),
              ),
            ],
          ),
    );

    emailCtrl.dispose(); // Pulizia del controller
  }

  // ─── Validators ─────────────────────────────────────────────────────────────

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Inserisci la tua email.';
    final reg = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!reg.hasMatch(v.trim())) return 'Formato email non valido.';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Inserisci la password.';
    if (v.length < 6) return 'Minimo 6 caratteri.';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v != _regPassCtrl.text) return 'Le password non coincidono.';
    return null;
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Reattività corretta agli errori tramite ref.listen
    ref.listen<AsyncValue<void>>(authNotifierProvider, (previous, next) {
      if (next is AsyncError) {
        final e = next.error;
        final msg =
            e is FirebaseAuthException
                ? authErrorMessage(e)
                : 'Si è verificato un errore. Riprova.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo ─────────────────────────────────────────────────
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.note_alt,
                        size: 46,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Noteep',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Il tuo taccuino digitale',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Tabs ─────────────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: colorScheme.onPrimary,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      tabs: const [
                        Tab(text: 'Accedi'),
                        Tab(text: 'Registrati'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Tab Views ─────────────────────────────────────────────
                  // AnimatedSize gestisce dinamicamente l'altezza in base al tab selezionato ed eventuali errori.
                  // L'altezza base è scalata con il text scale factor di sistema per evitare overflow
                  // quando l'utente ha impostato un testo più grande per accessibilità.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      height: MediaQuery.textScalerOf(context).scale(350),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _LoginTab(
                            formKey: _loginFormKey,
                            emailCtrl: _loginEmailCtrl,
                            passCtrl: _loginPassCtrl,
                            onSubmit: isLoading ? null : _loginWithEmail,
                            onForgotPassword: _showResetPasswordDialog,
                            validateEmail: _validateEmail,
                            validatePassword: _validatePassword,
                          ),
                          _RegisterTab(
                            formKey: _registerFormKey,
                            emailCtrl: _regEmailCtrl,
                            passCtrl: _regPassCtrl,
                            confirmPassCtrl: _regConfirmPassCtrl,
                            onSubmit: isLoading ? null : _registerWithEmail,
                            validateEmail: _validateEmail,
                            validatePassword: _validatePassword,
                            validateConfirmPassword: _validateConfirmPassword,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Loading indicator ─────────────────────────────────────
                  if (isLoading) ...[
                    const SizedBox(height: 12),
                    const Center(child: LinearProgressIndicator()),
                  ],

                  const SizedBox(height: 24),

                  // ── Divider ───────────────────────────────────────────────
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'oppure',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.outline),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Google Button ─────────────────────────────────────────
                  _GoogleSignInButton(
                    onPressed: isLoading ? null : _signInWithGoogle,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Login Tab ────────────────────────────────────────────────────────────────

class _LoginTab extends StatefulWidget {
  const _LoginTab({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.validateEmail,
    required this.validatePassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final VoidCallback? onSubmit;
  final VoidCallback onForgotPassword;
  final FormFieldValidator<String> validateEmail;
  final FormFieldValidator<String> validatePassword;

  @override
  State<_LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<_LoginTab> {
  bool _passVisible = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: widget.emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: widget.validateEmail,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: widget.passCtrl,
            obscureText: !_passVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => widget.onSubmit?.call(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _passVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _passVisible = !_passVisible),
              ),
            ),
            validator: widget.validatePassword,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
              ),
              child: const Text('Password dimenticata?'),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.onSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Accedi', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ─── Register Tab ─────────────────────────────────────────────────────────────

class _RegisterTab extends StatefulWidget {
  const _RegisterTab({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmPassCtrl,
    required this.onSubmit,
    required this.validateEmail,
    required this.validatePassword,
    required this.validateConfirmPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmPassCtrl;
  final VoidCallback? onSubmit;
  final FormFieldValidator<String> validateEmail;
  final FormFieldValidator<String> validatePassword;
  final FormFieldValidator<String> validateConfirmPassword;

  @override
  State<_RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<_RegisterTab> {
  bool _passVisible = false;
  bool _confirmPassVisible = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: widget.emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: widget.validateEmail,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: widget.passCtrl,
            obscureText: !_passVisible,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _passVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _passVisible = !_passVisible),
              ),
            ),
            validator: widget.validatePassword,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: widget.confirmPassCtrl,
            obscureText: !_confirmPassVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => widget.onSubmit?.call(),
            decoration: InputDecoration(
              labelText: 'Conferma password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _confirmPassVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed:
                    () => setState(
                      () => _confirmPassVisible = !_confirmPassVisible,
                    ),
              ),
            ),
            validator: widget.validateConfirmPassword,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: widget.onSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Crea account', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ─── Google Sign-In Button ────────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'G',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.warmBrown,
            ),
          ),
          const SizedBox(width: 10),
          const Text('Continua con Google', style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
