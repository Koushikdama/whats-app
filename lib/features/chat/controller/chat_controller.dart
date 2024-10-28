import 'dart:io';

import 'package:chatting_app/Common/enums/message_enmu.dart';
import 'package:chatting_app/User_info/Controller/userController.dart';

import 'package:chatting_app/features/chat/model/chat_contact.dart';

import 'package:chatting_app/features/chat/repository/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatcontroller = Provider((ref) {
  final chatrepo = ref.watch(chatrepository);
  return ChatController(chatrepository: chatrepo, ref: ref);
});

class ChatController {
  final ChatRepository chatrepository;
  final ProviderRef ref;

  ChatController({required this.chatrepository, required this.ref});

  void sendMessage(BuildContext context, String text, String receiveruserid) {
    print("controller send msg");
    ref.read(userDataAuthprovider).whenData(
          (value) => chatrepository.SendTextMessage(
            context: context,
            text: text,
            receiverUserId: receiveruserid,
            senderUser: value!,
          ),
        );
    print("end controller");
  }

  Stream<List<ChatContact>> chatContact({bool status = false}) async* {
    print("123contro heyller");
    // Use yield* to yield values from the inner stream
    yield* chatrepository.getChatContacts(status);
  }

  Stream<List<Map<String, dynamic>>> contactmessages(String receiverId) {
    return chatrepository.getDayChats(receiverId);
  }

  void sendfileMessage(BuildContext context, File file, String receiveruserid,
      MessageEnum type) {
    ref.read(userDataAuthprovider).whenData(
          (value) => chatrepository.sendfileMessages(
            context: context,
            file: file,
            receiveruserid: receiveruserid,
            senderuserdata: value!,
            type: type,
            ref: ref,
          ),
        );
  }
}
