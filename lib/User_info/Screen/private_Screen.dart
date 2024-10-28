// ignore_for_file: use_build_context_synchronously

import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Controller/userController.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivateSetting extends ConsumerStatefulWidget {
  static const routeName = "/user-private-screen";
  const PrivateSetting({super.key});

  @override
  _PrivateSettingsState createState() => _PrivateSettingsState();
}

class _PrivateSettingsState extends ConsumerState<PrivateSetting> {
  final TextEditingController _nameController = TextEditingController();
  String _nameError = ''; // To hold error messages for name validation
  File? _Private_profile_Image; // To hold the selected profile image

  Future<void> selectImage() async {
    // Function to select image from gallery
    File? selectedImage = await pickImageFromGallery(context);
    if (selectedImage != null) {
      setState(() {
        _Private_profile_Image = selectedImage; // Update profile image
      });
    } else {
      // Optionally show a message if the image selection was canceled or failed
      showSnackBar(context, "Image selection canceled or failed.");
    }
  }

  void savedata() async {
    String privateName = _nameController.text;
    File? privateImage = _Private_profile_Image;
    ref
        .read(authControllerProvider)
        .saveprivatedetails(context, privateName, privateImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Private Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              // Handle the save action here
              if (_nameController.text.isEmpty) {
                setState(() {
                  _nameError = 'Please enter a private name.';
                });
              } else if (_nameController.text.length > 30) {
                setState(() {
                  _nameError = 'Name cannot exceed 30 characters.';
                });
              } else {
                savedata();
                Navigator.pop(context); // Navigate back to the previous screen
                // Optionally, save the data or perform other actions
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Private image avatar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60, // Size of the avatar
                      backgroundImage: _Private_profile_Image != null
                          ? FileImage(
                              _Private_profile_Image!) // Show selected image
                          : const AssetImage(
                              'assets/animation/ch.e.s.s.jpeg', // Default image
                            ) as ImageProvider<Object>,
                    ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        icon: const Icon(
                          Icons.add_a_photo,
                        ),
                        onPressed: selectImage, // Select image on tap
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Private name text field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Private Name',
                      border: const OutlineInputBorder(),
                      errorText: _nameError.isEmpty ? null : _nameError,
                    ),
                    maxLength: 30, // Maximum length of 30 characters
                    onChanged: (value) {
                      setState(() {
                        _nameError = ''; // Clear error when user types
                      });
                    },
                  ),
                  const SizedBox(height: 5), // Space between field and counter
                  // Character count display
                  Text(
                    '${_nameController.text.length}/30',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Space before the button
            // Button to see seen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  // Implement see seen functionality here
                },
                child: const Text('See Seen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
