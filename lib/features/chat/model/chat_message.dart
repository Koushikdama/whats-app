// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:chatting_app/Common/enums/message_enmu.dart';

class MESSAGES {
  final String senderId;
  final String receiverId;
  final String text;
  final MessageEnum type;
  final DateTime timeSent;
  final String messageId;
  final bool isSeen;
  final String repliedMessage;
  final String repliedTo;
  final MessageEnum repliedMessageType;

  MESSAGES({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.timeSent,
    required this.messageId,
    required this.isSeen,
    required this.repliedMessage,
    required this.repliedTo,
    required this.repliedMessageType,
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
      'repliedMessage': repliedMessage,
      'repliedTo': repliedTo,
      'repliedMessageType': repliedMessageType.type,
    };
  }

  factory MESSAGES.fromMap(Map<String, dynamic> map) {
    return MESSAGES(
      senderId: (map['senderId'] ?? '') as String,
      receiverId: (map['receiverId'] ?? '') as String,
      text: (map['text'] ?? '') as String,
      type: (map['type'] as String).toEnum(),
      timeSent:
          DateTime.fromMillisecondsSinceEpoch((map['timeSent'] ?? 0) as int),
      messageId: (map['messageId'] ?? '') as String,
      isSeen: (map['isSeen'] ?? false) as bool,
      repliedMessage: (map['repliedMessage'] ?? '') as String,
      repliedTo: (map['repliedTo'] ?? '') as String,
      repliedMessageType: (map['repliedMessageType'] as String).toEnum(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MESSAGES.fromJson(String source) =>
      MESSAGES.fromMap(json.decode(source) as Map<String, dynamic>);
}

class day_chats {
  final DateTime date; // Corrected to DateTime
  final bool isvanish;
  final List<MESSAGES> messages; // Updated to list of messages

  day_chats({
    required this.date,
    required this.isvanish,
    required this.messages,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date.millisecondsSinceEpoch,
      'isvanish': isvanish,
      'messages': messages.map((x) => x.toMap()).toList(),
    };
  }

  factory day_chats.fromMap(Map<String, dynamic> map) {
    return day_chats(
      date: DateTime.fromMillisecondsSinceEpoch((map['date'] ?? 0) as int),
      isvanish: (map['isvanish'] ?? false) as bool,
      messages: List<MESSAGES>.from(
        (map['messages'] as List<int>).map<MESSAGES>(
          (x) => MESSAGES.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class friend {
  final String receiverid;
  final String bgimage;
  final bool isLock;
  final List<day_chats> chat; // Changed to List for multiple day_chats

  friend({
    required this.receiverid,
    required this.bgimage,
    required this.isLock,
    required this.chat,
  });

  Map<String, dynamic> toMap() {
    return {
      'receiverid': receiverid,
      'bgimage': bgimage,
      'isLock': isLock,
      'chat': chat
          .map((dayChat) => dayChat.toMap())
          .toList(), // Map each day_chat to a map
    };
  }
}
