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
import 'settings/data_actions.dart';

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

/// Uid of the signed-in user, or `''` when signed out. The data notifiers
/// watch this instead of [currentUserProvider], so tests can override it.
final currentUidProvider = Provider<String>((ref) {
  return ref.watch(currentUserProvider)?.uid ?? '';
});

// ─── Auth operations notifier ─────────────────────────────────────────────────

class AuthNotifier extends Notifier<AsyncValue<void>> {
  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);
  final _googleSignIn = GoogleSignIn();

  @override
  AsyncValue<void> build() {
    ref.watch(firebaseAuthProvider);
    return const AsyncValue.data(null);
  }

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

  // ── Delete Account ──────────────────────────────────────────────────────────

  /// Re-authenticates the current user ([password] for email accounts, the
  /// Google flow otherwise), wipes all their Firestore data, then deletes
  /// the Firebase Auth user and signs out.
  ///
  /// Re-authentication comes first so a wrong password or a cancelled
  /// Google flow leaves both data and account untouched. Returns `false`
  /// when the user cancels the Google flow; throws [FirebaseAuthException]
  /// on auth failures and Firestore errors (e.g. offline) on data wipe.
  Future<bool> deleteAccount({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No signed-in user');

    final AuthCredential credential;
    if (password != null) {
      credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
    } else {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;
      final googleAuth = await googleUser.authentication;
      credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    }
    await user.reauthenticateWithCredential(credential);

    final actions = ref.read(dataActionsProvider);
    await actions.wipeRemoteData();
    await user.delete();
    await actions.wipeLocalData();
    await _googleSignIn.signOut();
    state = const AsyncValue.data(null);
    return true;
  }
}

/// Whether [user] signs in with email and password (so deleting the account
/// asks for the password) rather than only with Google.
bool usesPasswordSignIn(User user) =>
    user.providerData.any((p) => p.providerId == EmailAuthProvider.PROVIDER_ID);

final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<void>>(
  AuthNotifier.new,
);

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
    case 'user-mismatch':
      return 'L\'account scelto non è quello con cui hai effettuato l\'accesso.';
    case 'requires-recent-login':
      return 'Per sicurezza, esci e accedi di nuovo prima di riprovare.';
    default:
      return 'Si è verificato un errore. Riprova.';
  }
}
