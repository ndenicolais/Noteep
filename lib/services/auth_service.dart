import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:noteep/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Logger _logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? get currentUser => _auth.currentUser;

  // SIGNUP
  Future<User?> signUpWithEmailPassword(
      UserModel user, String name, String email, String password) async {
    UserModel user = UserModel(
      userEmail: email,
      userName: name,
    );

    final emailCheck = await _firestore
        .collection('users')
        .where('userEmail', isEqualTo: user.userEmail)
        .get();

    if (emailCheck.docs.isNotEmpty) {
      throw Exception("email_already_register");
    }

    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: user.userEmail,
      password: password,
    );
    _logger.i("User successfully registered: ${user.userEmail}");

    await _firestore
        .collection('users')
        .doc(userCredential.user?.uid)
        .set(user.toFirestore());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', true);
    await prefs.setString('user_id', userCredential.user?.uid ?? '');

    return userCredential.user;
  }

  // LOGIN
  Future<User?> loginWithEmailPassword(
      String email, String password, bool rememberMe) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('userEmail', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("email_not_found");
      }

      var userDoc = snapshot.docs.first;
      String primaryEmail = userDoc['userEmail'];
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: primaryEmail.trim(),
        password: password.trim(),
      );

      if (rememberMe) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', true);
        await prefs.setString('user_id', userCredential.user?.uid ?? '');
      }

      return userCredential.user;
    } catch (e) {
      if (e.toString().contains("wrong-password")) {
        throw Exception("invalid_password");
      }
      rethrow;
    }
  }

  // LOGIN W GOOGLE
  Future<User?> loginWithGoogle(BuildContext context, bool rememberMe) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          UserModel newUser = UserModel(
            userEmail: user.email!,
            userName: user.displayName ?? 'User ${user.uid}',
            userImage: user.photoURL,
            userDate: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(newUser.toFirestore());

          _logger.i("User created on Firestore with Google: ${user.email}");
        }
      }

      if (rememberMe) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', true);
        await prefs.setString('user_id', userCredential.user?.uid ?? '');
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // USER DETAILS
  Future<UserModel?> getUserDetails(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return UserModel.fromFirestore(userDoc.data()!);
    } else {
      throw Exception("User not founded on Firestore.");
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await googleSignOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');
      await prefs.remove('user_id');
    } catch (e) {
      throw Exception('Error during logout.');
    }
  }

  // LOGOUT FROM GOOGLE
  Future<void> googleSignOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  // RESET PASSWORD
  Future<String> resetPassword(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('userEmail', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("email_not_found");
      }

      await _auth.sendPasswordResetEmail(email: email);

      return email;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // DELETE
  Future<void> deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      if (user.providerData
          .any((userInfo) => userInfo.providerId == 'google.com')) {
        await _googleSignIn.signOut();
      }

      try {
        await _deleteUserDatabase(user.uid);
        await user.delete();
        await logout();
        await googleSignOut();
      } catch (e) {
        throw Exception("Error while deleting: $e");
      }
    } else {
      throw Exception("No user logged in.");
    }
  }

  // Function to delete user data from the Firestore database
  Future<void> _deleteUserDatabase(String userId) async {
    try {
      QuerySnapshot notesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .get();

      for (DocumentSnapshot doc in notesSnapshot.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception("Error during user document deletion: $e");
    }
  }
}
