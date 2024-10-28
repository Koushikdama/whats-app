import 'dart:async';

import 'package:chatting_app/User_info/Screen/user_details.dart';
import 'package:chatting_app/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

class Emailverification extends StatefulWidget {
  const Emailverification({super.key});

  @override
  State<Emailverification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<Emailverification> {
  late Timer timer; // Moved timer inside the state class

  @override
  void initState() {
    super.initState();
    // Set up a periodic timer that checks email verification status
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      //print("Checking email verification status...");
      await FirebaseAuth.instance.currentUser?.reload(); // Reload the user
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        timer.cancel();
        // Navigate to the user details screen if email is verified
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserDetails()),
        );
      }
    });
  }

  void resend(BuildContext context) {
    // Resend email verification
    AuthService authService = AuthService();
    authService.sendEmailVerification(context);
  }

  @override
  void dispose() {
    // Cancel the timer to avoid memory leaks
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email Verification"),
      ),
      backgroundColor: Colors.white, // Set background color to white
      body: Center(
        child: Lottie.asset(
          'assets/animation/Animation.json', // Corrected path case-sensitivity
          width: 200,
          height: 200,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          resend(context); // Corrected to use an anonymous function
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
