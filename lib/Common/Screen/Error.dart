import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ErrorScreen extends StatelessWidget {
  String error;
  ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(error)),
    );
  }
}
