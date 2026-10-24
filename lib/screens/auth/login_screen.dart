// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under a source-available, non-commercial license. See LICENSE.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_spacing.dart';
import 'login_forms.dart';
import 'login_widgets.dart';
import 'reset_password_dialog.dart';

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

  Future<void> _resetPassword() async {
    final email = await showResetPasswordDialog(
      context,
      initialEmail: _loginEmailCtrl.text,
    );
    if (email == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    await ref.read(authNotifierProvider.notifier).sendPasswordResetEmail(email);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.loginResetEmailSent),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                ? authErrorMessage(context.l10n, e)
                : context.l10n.commonGenericError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      }
    });

    final isLoading = ref.watch(authNotifierProvider) is AsyncLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  const LoginHeader(),
                  const SizedBox(height: AppSpacing.xxl),
                  LoginTabBar(controller: _tabController),
                  const SizedBox(height: 28),

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
                          LoginForm(
                            formKey: _loginFormKey,
                            emailCtrl: _loginEmailCtrl,
                            passCtrl: _loginPassCtrl,
                            onSubmit: isLoading ? null : _loginWithEmail,
                            onForgotPassword: _resetPassword,
                          ),
                          RegisterForm(
                            formKey: _registerFormKey,
                            emailCtrl: _regEmailCtrl,
                            passCtrl: _regPassCtrl,
                            confirmPassCtrl: _regConfirmPassCtrl,
                            onSubmit: isLoading ? null : _registerWithEmail,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isLoading) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Center(child: LinearProgressIndicator()),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  const OrDivider(),
                  const SizedBox(height: 18),
                  GoogleSignInButton(
                    onPressed: isLoading ? null : _signInWithGoogle,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
