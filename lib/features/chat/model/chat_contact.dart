// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:chatting_app/Common/enums/message_enmu.dart';

class ChatContact {
  final String name;
  final String profilepic;
  final DateTime timetosent;
  final String contactId;
  final String lastmessage;

  ChatContact(
      {required this.name,
      required this.profilepic,
      required this.timetosent,
      required this.contactId,
      required this.lastmessage});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilepic': profilepic,
      'timetosent': timetosent.millisecondsSinceEpoch,
      'contactId': contactId,
      'lastmessage': lastmessage,
    };
  }

  factory ChatContact.fromMap(Map<String, dynamic> map) {
    return ChatContact(
      name: (map['name'] ?? '') as String,
      profilepic: (map['profilepic'] ?? '') as String,
      timetosent:
          DateTime.fromMillisecondsSinceEpoch((map['timetosent'] ?? 0) as int),
      contactId: (map['contactId'] ?? '') as String,
      lastmessage: (map['lastmessage'] ?? '') as String,
    );
  }
}

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'type': type.type,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'messageId': messageId,
      'isSeen': isSeen,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: (map['senderId'] ?? '') as String,
      receiverId: (map['receiverId'] ?? '') as String,
      text: (map['text'] ?? '') as String,
      type: (map['type'] as String).toEnum(),
      timeSent:
          DateTime.fromMillisecondsSinceEpoch((map['timeSent'] ?? 0) as int),
      messageId: (map['messageId'] ?? '') as String,
      isSeen: (map['isSeen'] ?? false) as bool,
    );
  }
}
//(map['type'] as String).toEnum(),