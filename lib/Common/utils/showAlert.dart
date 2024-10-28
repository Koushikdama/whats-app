import 'dart:io';
import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context, File image) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(""),
        insetPadding:
            EdgeInsets.zero, // Remove default padding around the dialog
        contentPadding:
            EdgeInsets.zero, // Remove default padding around the content
        content: SizedBox(
          width: MediaQuery.of(context).size.width *
              0.4, // Take 90% of screen width
          height: MediaQuery.of(context).size.height *
              0.4, // Take 70% of screen height
          child: Image.file(
            image,
            fit: BoxFit.cover, // Make the image cover the available space
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}

void showAlertDialogpassword(BuildContext context, Function(String) onSubmit) {
  // Variable to hold the password text
  String password = '';
  // Variable to toggle the password visibility
  bool isObscured = true;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          "Enter Password",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Rounded corners
        ),
        contentPadding:
            EdgeInsets.all(20.0), // Padding around the dialog content
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4, // 40% of screen width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: isObscured,
                onChanged: (value) {
                  password = value; // Update the password variable
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        10.0), // Rounded corners for the TextField
                    borderSide: BorderSide(color: Colors.blue), // Border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        BorderSide(color: Colors.blueAccent, width: 2.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      // Toggle password visibility
                      isObscured = !isObscured;
                      // Update the state to reflect the change in visibility
                      (context as Element).markNeedsBuild();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20), // Space between TextField and buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.red, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        onSubmit(''); // Return empty string on cancel
                      },
                    ),
                  ),
                  const SizedBox(width: 10), // Space between buttons
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blueAccent, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Submit'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        onSubmit(password); // Return the password on submit
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
