import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';
import 'package:chatting_app/features/chat/screens/mobile_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];

    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
        print("conatcts==${(contacts[0].photo)}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(Contact selectedContact, BuildContext context) async {
    print("repository select contact");
    try {
      print("try");
      var userCollection = await firestore.collection('users').get();
      print("usercollection$userCollection");
      bool isFound = false;

      for (var document in userCollection.docs) {
        print("documents ==${document.data()}");
        var userData = UserProfile.fromMap(document.data());
        print("userdata $userData");
        print(userData.phoneNumber);
        //String selectedPhoneNum = selectedContact.phones[0].number.replaceAll(
        //  ' ',
        //  '',
        // );
        String cleanedNumber =
            selectedContact.phones[0].number.replaceAll(RegExp(r'\D'), '');
        print("cleaned number$cleanedNumber");
        if (cleanedNumber == userData.phoneNumber) {
          isFound = true;
          print("firstname ${userData.firstName} and uid ${userData.uid}");
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
      showSnackBar(context, e.toString());
    }
  }
}
