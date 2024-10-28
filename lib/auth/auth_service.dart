// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      sendEmailVerification(context);
      return cred.user;
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Something went wrong");
    }
    return null;
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Something went wrong");
    }
  }

  // EMAIL VERIFICATION
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        log("Sending email verification...");
        await user.sendEmailVerification(); // Await the Future
        showSnackBar(context, 'Email verification sent!');
      } else {
        showSnackBar(context, 'User is already verified or not logged in.');
      }
    } on FirebaseAuthException catch (e) {
      log("Error sending email verification: ${e.message}");
      showSnackBar(
          context, e.message ?? 'An error occurred'); // Display error message
    } catch (e) {
      log("Unexpected error: $e");
      showSnackBar(context, 'An unexpected error occurred');
    }
  }
}
