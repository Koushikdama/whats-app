// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:chatting_app/Common/utils/showAlert.dart';
import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Controller/userController.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';
import 'package:chatting_app/User_info/Model/getlocation.dart';
import 'package:chatting_app/User_info/Screen/private_Screen.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
// Import your UserProfile model
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package

class UserDetails extends ConsumerStatefulWidget {
  static const routeName = "/user-details-screen";

  const UserDetails({super.key});

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends ConsumerState<UserDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool _isPrivate = false;
  bool _nearbyMe = false;
  File? profileImage; // Profile image file
  File? backgroundImage; // Background image file
  Color color = Colors.grey;
  Country? country;
  String profileurl = "";
  String backgroundurl = "";

  UserProfile? userProfile; // Add a variable to hold user profile data

  @override
  void initState() {
    super.initState();
    // Add listeners to the text controllers for real-time character count
    _nameController.addListener(() {
      setState(() {}); // Rebuild to show updated character count
    });
    _descriptionController.addListener(() {
      setState(() {}); // Rebuild to show updated character count
    });
    _phoneNumberController.addListener(() {
      setState(() {}); // Rebuild to show updated character count
    });

    _fetchUserData(); // Fetch user data when the widget is initialized
  }

  Future<void> _fetchUserData() async {
    String uid = FirebaseAuth
        .instance.currentUser!.uid; // Replace this with the actual user ID
    UserProfile? fetchedUserData = await fetchUserData(uid);
    if (fetchedUserData != null) {
      setState(() {
        userProfile = fetchedUserData; // Store fetched user data
        _nameController.text = fetchedUserData.firstName;
        _descriptionController.text = fetchedUserData.describes.descriptio;
        _phoneNumberController.text = fetchedUserData.phoneNumber;
        _isPrivate = fetchedUserData.privateSettings.isPrivate;
        _nearbyMe = fetchedUserData.nearbyCoordinates.nearby;
        profileurl = fetchedUserData.profile;
        backgroundurl = fetchedUserData.bgImage;
        // print(backgroundurl);
        // If you have profile and background images URLs, you can also load them here
      });
    }
  }

  Future<UserProfile?> fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      return null;
    }
  }

  void pickercountry() {
    showCountryPicker(
      context: context,
      onSelect: (Country country) {
        setState(() {
          country = country;
        });
      },
    );
  }

  void nearbyme(BuildContext context) async {
    try {
      Position position = await determinePosition();
      //print(
      // "latitude: ${position.latitude} & longitude: ${position.longitude} && location${position.timestamp}");
      ref
          .read(authControllerProvider)
          .saveuserlocation(context, position.latitude, position.longitude);

      // If the position is successfully retrieved, set nearbyMe to true
      setState(() {
        _nearbyMe = true;
      });
    } catch (e) {
      // If there is an error, such as permission denied, set nearbyMe to false
      setState(() {
        _nearbyMe = false;
      });
    }
  }

  Future<void> storeUserData() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();
    String phoneNumber = _phoneNumberController.text.trim();

    if (_formKey.currentState?.validate() == true) {
      ref.read(authControllerProvider).saveUserDataToFirebase(
          context: context,
          name: name,
          profilePic: profileImage,
          description: description,
          bgimage: backgroundImage,
          mobilenumber: phoneNumber,
          isprivate: _isPrivate,
          isprivateactivate: false,
          nearbyme: _nearbyMe);
    } else {
      showSnackBar(
          context, "Please fill in all fields correctly."); // Alert user
    }
  }

  Future<void> selectImage(String type) async {
    File? selectedImage = await pickImageFromGallery(context);
    if (selectedImage != null) {
      setState(() {
        if (type == "PROFILE") {
          profileurl = "";
          profileImage = selectedImage; // Update profile image
        } else if (type == "BACKGROUND_IMAGE") {
          backgroundurl = "";
          backgroundImage = selectedImage; // Update background image
          color = Colors.white70; // Change color on background image selection
        }
      });
    } else {
      showSnackBar(context, "Image selection canceled or failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          IconButton(
            onPressed: storeUserData, // Trigger user data saving
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: backgroundImage != null || backgroundurl != ""
              ? DecorationImage(
                  image: backgroundurl == ""
                      ? FileImage(backgroundImage!)
                      : NetworkImage(backgroundurl),
                  fit: BoxFit.cover,
                )
              : null,
          color: backgroundImage == null && backgroundurl == ""
              ? Theme.of(context).scaffoldBackgroundColor
              : null,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          profileImage == null && profileurl == ""
                              ? GestureDetector(
                                  onTap: () => selectImage("PROFILE"),
                                  child: CircleAvatar(
                                    radius: screenWidth * 0.15,
                                    backgroundImage: const AssetImage(
                                        "assets/images/empty_image.jpg"),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () =>
                                      showAlertDialog(context, profileImage!),
                                  child: CircleAvatar(
                                    radius: screenWidth * 0.15,
                                    backgroundImage: profileurl == ""
                                        ? FileImage(profileImage!)
                                        : NetworkImage(profileurl),
                                  ),
                                ),
                          Positioned(
                            left: 70,
                            bottom: -10,
                            child: IconButton(
                              onPressed: () => selectImage("PROFILE"),
                              icon: const Icon(Icons.add_a_photo),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name (max 30 characters)',
                      maxLength: 30,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description (max 30 characters)',
                      maxLength: 30,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextFieldWithPrefixIcon(
                        controller: _phoneNumberController,
                        label: 'Phone Number (10 digits)',
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number.';
                          }
                          // Check if the input contains only digits
                          if (!RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Please enter numbers only.';
                          }
                          // Check if the input is exactly 10 digits long
                          if (value.length != 10) {
                            return 'Please enter a valid 10-digit phone number.';
                          }
                          return null; // If all validations pass
                        }),
                    const SizedBox(height: 20),
                    const Divider(),
                    // Private Settings - Navigates to PrivateSettings screen when clicked
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, PrivateSetting.routeName,
                            arguments: {"status": _isPrivate});
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Private Settings'),
                              SizedBox(height: 8),
                              Text(
                                "Click to change settings",
                                style: TextStyle(color: Colors.white30),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isPrivate,
                            onChanged: (value) {
                              setState(() {
                                _isPrivate = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    // Nearby Me - Only toggles the switch without navigation
                    _buildSwitchTile(
                      title: 'Nearby Me',
                      onChanged: (value) {
                        setState(() {
                          _nearbyMe = value;
                        });
                        if (value) {
                          nearbyme(
                              context); // Check location when switch is turned on
                        } else {}
                      },
                      value: _nearbyMe,
                    ),
                    const Divider(),
                    _buildBackgroundImageSelector(screenWidth),
                    const Divider(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required int maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '${controller.text.length}/$maxLength',
      ),
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildTextFieldWithPrefixIcon({
    required TextEditingController controller,
    required String label,
    required int maxLength,
    TextInputType? keyboardType,
    required IconData prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '${controller.text.length}/$maxLength',
        prefixIcon: IconButton(
            onPressed: pickercountry,
            icon: country != null
                ? Text("+${country!.phoneCode}")
                : const Text("+91")),
      ),
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildBackgroundImageSelector(double screenWidth) {
    return Row(
      children: [
        const Text("Select background image"),
        SizedBox(width: screenWidth * 0.25),
        Stack(
          children: [
            CircleAvatar(
              radius: screenWidth * 0.1,
              backgroundImage: backgroundImage != null || backgroundurl != ""
                  ? backgroundurl == ""
                      ? FileImage(backgroundImage!)
                      : NetworkImage(backgroundurl)
                  : const AssetImage('assets/images/empty_image.jpg')
                      as ImageProvider<Object>,
            ),
            Positioned(
              left: 42,
              bottom: -10,
              child: IconButton(
                onPressed: () => selectImage("BACKGROUND_IMAGE"),
                icon: const Icon(Icons.add_a_photo),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
