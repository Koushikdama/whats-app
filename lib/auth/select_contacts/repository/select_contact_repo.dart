import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';
import 'package:chatting_app/auth/select_contacts/Model/contact_users.dart';
import 'package:chatting_app/features/chat/screens/mobile_chat_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectContactsRepositoryProvider = Provider(
  (ref) => SelectContactRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

class SelectContactRepository {
  final FirebaseFirestore firestore;

  SelectContactRepository({
    required this.firestore,
  });

  Stream<List<Contacts>> getContactsStream() async* {
    List<Contact> contacts = [];
    List<Contacts> contactses = [];
    bool isPrivate = false;
    Map<String, dynamic> users = {};
    List<Contacts> privateContacts = [];
    List<Contacts> usersNot = [];

    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);

        var privateIs =
            await getUserAttribute("isactivatePrivate").then((attributeValue) {
          isPrivate = attributeValue ?? false; // Set default to false if null
          return attributeValue;
        });

        users = await getUserAttribute("lockSettings").then((attributeValue) {
          users = attributeValue ?? {}; // Set default to an empty map if null
          return attributeValue;
        });

        for (Contact contact in contacts) {
          print("contact number ${contact.phones[0].toString()}");
          var data = await getUserByPhoneNumber(contact.phones[0].toString());
          print("data!.firstName: ${data?.firstName}");

          String formattedNumber =
              contact.phones[0].toString().replaceAll(RegExp(r'\D'), '');
          formattedNumber = formattedNumber.length > 10
              ? formattedNumber.substring(formattedNumber.length - 10)
              : formattedNumber;

          if (data?.firstName == null) {
            usersNot.add(Contacts(
                name: contact.displayName,
                description: "",
                profilepic:
                    'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png',
                phonenumber: formattedNumber,
                uid: "NOT"));
          }

          if ((users['users'] as List).contains(data?.uid)) {
            print("id executed ${contact.displayName}");
            privateContacts.add(Contacts(
                name: contact.displayName,
                description: data!.describes.descriptio,
                phonenumber: data.phoneNumber,
                profilepic: data.profile,
                uid: data?.uid ?? ""));
          } else {
            print("id executed ${contact.displayName}");
            contactses.add(Contacts(
                name: contact.displayName,
                description: data!.describes.descriptio,
                phonenumber: data.phoneNumber,
                profilepic: data.profile,
                uid: data.uid));
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    // Yield the final list based on isPrivate
    yield isPrivate ? privateContacts : [...contactses, ...usersNot];
  }

  void selectContact(Contacts selectedContact, BuildContext context) async {
    // print("repository select contact");
    try {
      // print("try");
      var userCollection = await firestore.collection('users').get();
      // print("usercollection$userCollection");
      bool isFound = false;

      for (var document in userCollection.docs) {
        // print("documents ==${document.data()}");
        var userData = UserProfile.fromMap(document.data());
        // print("userdata $userData");
        // print(userData.phoneNumber);
        //String selectedPhoneNum = selectedContact.phones[0].number.replaceAll(
        //  ' ',
        //  '',
        // );
        String cleanedNumber = selectedContact.phonenumber
            .replaceAll(RegExp(r'\D'), '')
            .substring(0, 10);
        // print("cleaned number$cleanedNumber");
        if (cleanedNumber == userData.phoneNumber) {
          isFound = true;
          // print("firstname ${userData.firstName} and uid ${userData.uid}");
          Navigator.pushNamed(
            context,
            MobileChatScreen.routeName,
            arguments: {
              'name': userData.firstName,
              'uid': userData.uid,
            },
          );
        }
      }

      if (!isFound) {
        showSnackBar(
          context,
          'This number does not exist on this app.',
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

/////////////////////////////////////////////////////////////////////////////////////
  Future<UserProfile?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      String formattedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
      formattedNumber = formattedNumber.length > 10
          ? formattedNumber.substring(formattedNumber.length - 10)
          : formattedNumber;
      print(
          "phoneNumber ${phoneNumber} and replace ${phoneNumber.replaceAll(RegExp(r'\D'), '').substring(0, 10)} and ^^^^^^^^^${formattedNumber}");
      // print(
      //     "phoneNumber.replaceAll(RegExp(r'\D'), '')${phoneNumber.replaceAll(RegExp(r'\D'), '').substring(0, 10)}");
      // Query the 'users' collection for a document with the specified phone number
      var querySnapshot = await firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedNumber)
          .get();

      // Check if any document was found
      if (querySnapshot.docs.isNotEmpty) {
        // Assuming the phone number is unique, get the first document
        var document = querySnapshot.docs.first;

        // Convert the document data to UserProfile
        var userData = UserProfile.fromMap(document.data());
        return userData; // Return the user profile
      }
    } catch (e) {
      print("Error fetching user by phone number: $e");
    }
    return null; // Return null if no user was found or an error occurred
  }

  Future<dynamic> getUserAttribute(String attributeName) async =>
      (await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get())
          .data()?['$attributeName'];
}
