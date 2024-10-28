// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:chatting_app/Common/Repository/commonFirebase.dart';

import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';
import 'package:chatting_app/screens/mobile_layout_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  Future<UserProfile?> getCurrentuserData() async {
    var userData =
        await firestore.collection("users").doc(auth.currentUser?.uid).get();
    UserProfile? user;
    if (userData.data() != null) {
      user = UserProfile.fromMap(userData.data()!);
    }
    return user;
  }

  void saveUserDataToFirebase(
      {required String name,
      required String description,
      required File? profilePic,
      required File? bgimage,
      required ProviderRef ref,
      required String mobilenumber,
      required BuildContext context,
      required bool isprivate,
      required bool isactivatePrivate,
      required bool nearbyme}) async {
    try {
      // Get the current user's UID
      String uid = auth.currentUser!.uid;
      User? currentUser = auth.currentUser;

      if (currentUser == null) {
        showSnackBar(context, 'User not authenticated.');
        return; // Exit if user is not authenticated
      }

      String photoUrl =
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';
      String bgPhotourl =
          'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

      // Upload profile picture if provided
      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'profilePic/$uid',
              profilePic,
            );
      }

      // Upload background image if provided
      if (bgimage != null) {
        bgPhotourl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'BG_IMAGE/$uid',
              bgimage,
            );
      }

      // Fetch the existing user data from Firestore to check if privateSettings exist
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(uid).get();
      PrivateSettings privateSettings;

      // Check if privateSettings already exist
      if (userDoc.exists && userDoc['privateSettings'] != null) {
        // If privateSettings already exist, do not update
        privateSettings = PrivateSettings.fromJson(userDoc['privateSettings']);
      } else {
        // If privateSettings do not exist, create new ones
        privateSettings = PrivateSettings(
            isPrivate: isprivate, privateName: name, privateImage: photoUrl);
      }
      NearbyCoordinates nearby =
          NearbyCoordinates(latitude: 0, longitude: 0, nearby: nearbyme);
      Description desc =
          Description(descriptio: description, dateTime: DateTime.now());
      //print("success");

      // Create the updated user profile
      var user = UserProfile(
          firstName: name,
          profile: photoUrl,
          describes: desc,
          privateSettings: privateSettings,
          nearbyCoordinates: nearby,
          inOnline: true,
          uid: uid,
          isactivatePrivate: isactivatePrivate,
          bgImage: bgPhotourl,
          groupId: [],
          phoneNumber: mobilenumber,
          lockSettings: LockSettings(isLock: false, password: "", users: []));

      // Update the user data in Firestore
      await firestore.collection('users').doc(uid).set(user.toMap());

      // Navigate to the next screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MobileLayoutScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      // Show error message if any exception occurs
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

  Future<void> savePrivateDetails({
    required String name,
    required File? image,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    String uid = auth.currentUser!.uid;

    // Get the 'isPrivate' field value
    var isPrivateValue = await getStatus('privateSettings.isPrivate');
    // print("repoisPrivateValue=${isPrivateValue} ");

    // Default private photo URL
    String privatePhotoUrl =
        'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png';

    // If image is provided, upload to Firebase Storage
    if (image != null) {
      try {
        privatePhotoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase(
              'private_profilePic/$uid',
              image,
            );
      } catch (e) {
        // print("Error uploading image: $e");
        showSnackBar(context, "Error uploading image");
        return; // Exit early if image upload fails
      }
    }

    // Create PrivateSettings object
    var privateSettings = PrivateSettings(
      isPrivate:
          isPrivateValue ?? false, // Handle null case with a default value
      privateName: name,
      privateImage: privatePhotoUrl,
    );
    // print("privateSettings =${privateSettings.isPrivate}");

    // Update Firestore with the new private settings
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'privateSettings': privateSettings.toJson(),
      });
      showSnackBar(context, "Private details updated successfully");
    } catch (e) {
      // print("Error updating private details: $e");
      showSnackBar(context, "Error updating private details");
    }
  }

  void updateLocation({
    required double latitude,
    required double longitude,
    required BuildContext context,
    required ProviderRef ref,
  }) async {
    // Retrieve the user's UID from the current authenticated user
    String uid = auth.currentUser!.uid;
    var isPrivateValue = await getStatus('nearbyCoordinates.nearby');

    // Create a NearbyCoordinates object with the provided latitude and longitude
    var userLocation = NearbyCoordinates(
      latitude: latitude,
      longitude: longitude,
      nearby: isPrivateValue ??
          false, // Assuming 'nearby' is required, you can adjust this if needed
    );

    try {
      // Update the 'nearbyCoordinates' field in the user's Firestore document
      await FirebaseFirestore.instance
          .collection('users') // Target the 'users' collection
          .doc(uid) // Target the specific user by their UID
          .update({
        'nearbyCoordinates': userLocation.toJson(), // Update the location
      });

      // Show a snackbar message to confirm the location update
      showSnackBar(context, "Location updated successfully");
    } catch (e) {
      // Log the error or show an error message in case of failure
      // print("Error updating location: $e");
      showSnackBar(context, "Failed to update location");
    }
  }

  Stream<UserProfile> userData(String userId) {
    // print("repo call");
    var data = firestore.collection('users').doc(userId).snapshots().map(
          (event) => UserProfile.fromMap(
            event.data()!,
          ),
        );
    // print("data repo ${data}");
    return data;
  }

  void setUserState(bool isonline) async {
    firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .update({'inOnline': isonline, 'isactivatePrivate': false});
    setisPrivate(false);
  }

  void setisPrivate(bool isprivate) async {
    firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .update({'isactivatePrivate': isprivate});
  }

  Future<bool> getPasswordAttribute(String password) async {
    try {
      // Reference the user's document
      DocumentSnapshot userDoc =
          await firestore.collection("users").doc(auth.currentUser!.uid).get();

      // Check if the document exists
      if (userDoc.exists) {
        print("id executer");
        // Retrieve a specific attribute value from the document
        Map<String, dynamic> userData = userDoc.data() as Map<String,
            dynamic>; // Replace 'password' with the actual attribute name
        // Optionally, compare with the provided password
        return userData['lockSettings']['password'] ==
            password; // Return true if they match
      } else {
        print("User document does not exist.");
        return false;
      }
    } catch (e) {
      print("Error retrieving password: $e");
      return false; // Return false in case of an error
    }
  }

  void lockStatus(BuildContext context, bool islock, String uid) async {
    // Reference to the user document
    final userDocRef = firestore.collection("users").doc(auth.currentUser!.uid);

    // Use a transaction to ensure atomicity
    await firestore.runTransaction((transaction) async {
      // Get the current data of the document
      DocumentSnapshot userDoc = await transaction.get(userDocRef);

      if (userDoc.exists) {
        // Cast the document data to Map<String, dynamic>
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        // print("userData ${userData}");

        // Get the current groupId array, default to an empty list if it doesn't exist
        // List<dynamic> lockusers = userData['lockSettings']['lockChats'] ?? [];
        List<dynamic> userslock = userData['lockSettings']['users'] ?? [];

        // print("lockusers == and ${userslock}");

        // Check if uid exists in the array
        if (islock) {
          if (userData['lockSettings']['password'] == "") {
            showSnackBar(context, "PLEASE SET PASSWORD FIRSTLY");
          } else {
            // Add uid if not already present
            if (!userslock.contains(uid)) {
              // print("if block lock statsu");

              userslock.add(uid);
            }
          }
        } else {
          // print("else block lock statsu");

          // Remove uid if it exists

          userslock.remove(uid);
        }

        // Update the document with the new groupId array
        transaction.update(userDocRef, {'lockSettings.users': userslock});
      }
    });
  }

  Future<UserProfile?> fetchProfileDetails(String receiverId) async {
    print("Repo receiver_id: $receiverId");

    try {
      // Await the result of the Firestore document fetch
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(receiverId)
          .get();

      // Check if the document exists
      if (userSnapshot.exists) {
        // Print the entire data
        print("User data: ${userSnapshot.data()}");

        // If you want to print specific fields
        var userData =
            userSnapshot.data() as Map<String, dynamic>; // Cast to a Map
        print("User Name: ${userData['firstName']}");
        print("User Email: ${userData['phoneNumber']}");
        print("users in list chart :${(userData["lockSettings"]['users'])}");
        List<Contact> contacts =
            await FlutterContacts.getContacts(withProperties: true);
        print(
            "contacts list${containsPhoneNumber(contacts, userData["phoneNumber"])}");
        UserProfile profileDetails = UserProfile(
          isactivatePrivate: userData['isactivatePrivate'] ?? false,
          firstName: userData['firstName'] ?? "Unknown",
          describes: Description.fromMap(userData['describes']),
          phoneNumber: userData['phoneNumber'] ?? '',
          profile: userData['profile'] ?? '',
          bgImage: userData['bgImage'] ?? '', // Ensure new fields are handled
          groupId: List<String>.from(userData['groupId'] ?? []),
          inOnline: userData['inOnline'] ?? false,
          uid: userData['uid'] ?? '',
          lockSettings: LockSettings.fromMap(
              userData['lockSettings'] ?? {}), // Handle lockSettings
          nearbyCoordinates:
              NearbyCoordinates.fromMap(userData['nearbyCoordinates'] ?? {}),
          privateSettings:
              PrivateSettings.fromMap(userData['privateSettings'] ?? {}),
        );
        print("userprofile ${profileDetails.bgImage}");
        return profileDetails;
        // Add other fields as necessary
      } else {
        print("No user found with the ID: $receiverId");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Map<String, dynamic> containsPhoneNumber(
      List<Contact> contacts, String numberToCheck) {
    // print("contacts: ${contacts}");

    // Remove the country code '+91' if it exists at the start of the number
    if (numberToCheck.startsWith('+91')) {
      numberToCheck = numberToCheck.replaceFirst('+91', '');
    }

    // Normalize the input number by removing non-digit characters
    String normalizedInput = numberToCheck.replaceAll(
        RegExp(r'\D'), ''); // Remove non-digit characters

    // If the number contains more than 10 digits, keep only the last 10 digits
    if (normalizedInput.length > 10) {
      normalizedInput = normalizedInput.substring(normalizedInput.length - 10);
    }

    for (var contact in contacts) {
      for (var phone in contact.phones) {
        // Normalize the phone number in the contact list for comparison
        String contactNumber = phone.normalizedNumber;

        // If the contact's normalized number has more than 10 digits, keep the last 10 digits
        if (contactNumber.length > 10) {
          contactNumber = contactNumber.substring(contactNumber.length - 10);
        }

        // print(
        //     "Checking contact phone: $contactNumber against normalized input: $normalizedInput");

        if (contactNumber == normalizedInput) {
          return {
            'exists': true,
            'displayName':
                contact.displayName // Return the display name if found
          }; // Number found
        }
      }
    }

    return {
      'exists': false,
      'displayName': null // Return null if not found
    }; // Number not found
  }

  Future<bool?> getStatus(String field) async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (docSnapshot.exists) {
      return docSnapshot.data()?[field] as bool?; // Return the field value
    }

    return null; // Return null if the document or field doesn't exist
  }
}
