// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ─── Firebase Auth instance ───────────────────────────────────────────────────

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

// ─── Auth state stream (null = not logged in) ─────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// ─── Convenience: current user (nullable) ─────────────────────────────────────

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).asData?.value;
});

// ─── Auth operations notifier ─────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._auth) : super(const AsyncValue.data(null));

  final FirebaseAuth _auth;
  final _googleSignIn = GoogleSignIn();

  // ── Google Sign-In ──────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the flow.
        state = const AsyncValue.data(null);
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ── Email / Password Sign-In ────────────────────────────────────────────────

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ── Register with Email / Password ─────────────────────────────────────────

  Future<void> registerWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ── Password Reset ──────────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ── Sign Out ────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
      return AuthNotifier(ref.watch(firebaseAuthProvider));
    });

// ─── Firebase error → Italian message ────────────────────────────────────────

String authErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'Nessun account trovato con questa email.';
    case 'wrong-password':
      return 'Password errata. Riprova.';
    case 'invalid-credential':
      return 'Credenziali non valide. Controlla email e password.';
    case 'email-already-in-use':
      return 'Questa email è già associata a un account.';
    case 'weak-password':
      return 'La password è troppo debole (min. 6 caratteri).';
    case 'invalid-email':
      return 'Formato email non valido.';
    case 'too-many-requests':
      return 'Troppi tentativi. Riprova più tardi.';
    case 'network-request-failed':
      return 'Errore di rete. Controlla la connessione.';
    default:
      return 'Si è verificato un errore. Riprova.';
  }
}
