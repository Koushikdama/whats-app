// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:chatting_app/Common/Repository/commonFirebase.dart';
import 'package:chatting_app/Common/enums/message_enmu.dart';
import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Model/UserModel.dart';
import 'package:chatting_app/features/chat/model/chat_contact.dart';
import 'package:chatting_app/features/chat/model/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final chatrepository = Provider((ref) => ChatRepository(
    firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance));

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  void SendTextMessage({
    required BuildContext context,
    required String text,
    required String receiverUserId,
    required UserProfile senderUser,
  }) async {
    //users->sender_user_id->receiver_user_id->messages->message_id->store messages
    try {
      var timeSent = DateTime.now();
      UserProfile receiverUserData;
      var user = await firestore.collection("users").doc(receiverUserId).get();

      receiverUserData = UserProfile.fromJson(user.data()!);

      var messageid = const Uuid().v1();
      _saveDataToContactSubCollection(
          senderUser, receiverUserData, text, timeSent, receiverUserId);

      ////////////////////////////////
      _savemessageSubcollection(
          receiverId: receiverUserId,
          text: text,
          timeSent: timeSent,
          messageType: MessageEnum.text,
          messageId: messageid,
          senderId: senderUser.uid);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void _saveDataToContactSubCollection(
    UserProfile senderuserdata,
    UserProfile receiveruserdata,
    String text,
    DateTime time,
    String recieverUserId,
  ) async {
    var receiverside = ChatContact(
        name: senderuserdata.firstName,
        profilepic: senderuserdata.profile,
        contactId: senderuserdata.uid,
        timetosent: time,
        lastmessage: text);

    await firestore
        .collection("users")
        .doc(recieverUserId)
        .collection("chats")
        .doc(senderuserdata.uid)
        .set(receiverside.toMap());
    var senderside = ChatContact(
        name: receiveruserdata.firstName,
        profilepic: receiveruserdata.profile,
        contactId: receiveruserdata.uid,
        timetosent: time,
        lastmessage: text);
    await firestore
        .collection("users")
        .doc(senderuserdata.uid)
        .collection("chats")
        .doc(receiveruserdata.uid)
        .set(senderside.toMap());
  }

  void _savemessageSubcollection({
    required String senderId,
    required String receiverId,
    required String text,
    required DateTime timeSent,
    required MessageEnum messageType, // Assuming MessageEnum is defined
    required String messageId,
  }) async {
    final DateTime now = DateTime.now(); // Current timestamp
    final String dateId = DateFormat('yyyy_MM_dd')
        .format(now); // Generate the date-based document ID

    DocumentReference dayChatRef = FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .collection('friends')
        .doc(receiverId)
        .collection('chats')
        .doc(dateId);

    DocumentReference receiversideRef = FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('friends')
        .doc(senderId)
        .collection('chats')
        .doc(dateId);

    try {
      // Create the new message object
      final message = MESSAGES(
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        timeSent: timeSent,
        type: messageType,
        messageId: messageId,
        isSeen: false,
      );

      // Get the current day's document to check if it exists
      DocumentSnapshot dayChatDoc = await dayChatRef.get();

      if (dayChatDoc.exists) {
        // If the document exists, append the new message to the 'messages' array
        await dayChatRef.update({
          'messages': FieldValue.arrayUnion([message.toMap()]),
        });
        await receiversideRef.update({
          'messages': FieldValue.arrayUnion([message.toMap()]),
        });
      } else {
        // If the document doesn't exist, create new documents with the message
        day_chats newDayChat = day_chats(
          date: now, // Use the current date for the new chat
          isvanish: false, // Default value for isvanish
          messages: [message], // Start with the new message
        );

        day_chats newReceiverChat = day_chats(
          date: now,
          isvanish: false,
          messages: [message],
        );

        await dayChatRef.set(newDayChat.toMap());
        await receiversideRef.set(newReceiverChat.toMap());
      }
    } catch (e) {}
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Stream<List<ChatContact>> getChatContacts(bool lock) async* {
    // Listen to the stream of excluded contact IDs (groupIds)
    await for (var excludedContactIds in getUserState()) {
      // print("excludedContactIds==$excludedContactIds");
      yield* firestore
          .collection("users")
          .doc(auth.currentUser!.uid)
          .collection("chats")
          .snapshots()
          .asyncMap((snapshot) async {
        List<ChatContact> contacts = [];

        for (var document in snapshot.docs) {
          var chatContact = ChatContact.fromMap(document.data());

          // Exclude contacts who are in the excludedContactIds list
          if (!lock) {
            // print("if block execute means unlock users");
            if (!excludedContactIds.contains(chatContact.contactId)) {
              var userData = await firestore
                  .collection("users")
                  .doc(chatContact.contactId)
                  .get();
              var user = UserProfile.fromMap(userData.data()!);
              contacts.add(ChatContact(
                name: user.firstName,
                profilepic: user.profile,
                timetosent: chatContact.timetosent,
                contactId: chatContact.contactId,
                lastmessage: chatContact.lastmessage,
              ));
            }
          } else {
            // print("else block execute means lock users");
            if (excludedContactIds.contains(chatContact.contactId)) {
              var userData = await firestore
                  .collection("users")
                  .doc(chatContact.contactId)
                  .get();
              var user = UserProfile.fromMap(userData.data()!);
              contacts.add(ChatContact(
                name: user.firstName,
                profilepic: user.profile,
                timetosent: chatContact.timetosent,
                contactId: chatContact.contactId,
                lastmessage: chatContact.lastmessage,
              ));
            }
          }
        }
        // print("contacts all +${contacts}");

        return contacts; // Return the filtered contacts list
      });
    }
  }

  /////////////////////////////////////////////////////////////////////////////////

  Stream<List<Map<String, dynamic>>> getDayChats(String receiverId) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("friends")
        .doc(receiverId)
        .collection("chats")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() ?? {}).toList();
    });
  }

  void sendfileMessages(
      {required BuildContext context,
      required File file,
      required String receiveruserid,
      required UserProfile senderuserdata,
      required ProviderRef ref,
      required MessageEnum type}) async {
    var timesent = DateTime.now();
    var messageid = const Uuid().v1();
    String imageUrl = await ref
        .read(commonFirebaseStorageRepositoryProvider)
        .storeFileToFirebase(
          "chat/${type.type}/${senderuserdata.uid}/$receiveruserid/$messageid",
          file,
        );
    UserProfile receiveruserdata;
    var userdata =
        await firestore.collection("users").doc(receiveruserid).get();
    receiveruserdata = UserProfile.fromMap(userdata.data()!);
    String contactmsg;
    switch (type) {
      case MessageEnum.image:
        contactmsg = "photo";
        break;
      case MessageEnum.video:
        contactmsg = "video";
        break;
      case MessageEnum.audio:
        contactmsg = "audio";
        break;
      case MessageEnum.gif:
        contactmsg = "gif";
        break;
      default:
        contactmsg = "text";
    }

    try {
      _saveDataToContactSubCollection(senderuserdata, receiveruserdata,
          contactmsg, timesent, receiveruserid);
      _savemessageSubcollection(
          senderId: senderuserdata.uid,
          receiverId: receiveruserid,
          text: imageUrl,
          timeSent: timesent,
          messageType: type,
          messageId: messageid);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Stream<List<String>> getUserState() async* {
    try {
      // Listen to real-time updates of the user document using snapshots()
      Stream<DocumentSnapshot<Map<String, dynamic>>> userStream =
          firestore.collection("users").doc(auth.currentUser!.uid).snapshots();

      List<String> previousGroupId = [];

      await for (var docSnapshot in userStream) {
        if (docSnapshot.exists) {
          // Access the 'groupId' attribute safely and cast to List<String>
          List<String> groupId = List<String>.from(
              docSnapshot.data()?['lockSettings']['users'] ?? []);

          // Print Group ID

          // Yield the result only if the groupId has changed to avoid unnecessary renders
          if (groupId != previousGroupId) {
            yield groupId;
            previousGroupId = groupId;
          }
        } else {
          // print("User document does not exist.");
          yield []; // Yield an empty list if document doesn't exist
        }
      }
    } catch (e) {
      // print("Error retrieving user state: $e");
      yield []; // Yield an empty list in case of error
    }
  }

//////////////////////////////////////////////////////////////////////////////////

/////////////////////////
}

Future<void> updateChatIsVanish(
    String loginid, String receiverid, String date, bool status) async {
  try {
    // Get the current user's ID

    // Reference to the specific chat document
    await FirebaseFirestore.instance
        .collection('users')
        .doc(loginid)
        .collection('friends')
        .doc(receiverid) // Use the correct receiverId for friend document
        .collection('chats')
        .doc(
            date) // Use chatDate passed to the function to refer to the specific chat
        .update({'isvanish': status});

    //print('Document updated successfully.');
  } catch (e) {
    //print('Error updating document: $e');
  }
}
