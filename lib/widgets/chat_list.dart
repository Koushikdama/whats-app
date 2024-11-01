import 'package:chatting_app/Common/Providers/messsage_reply_provider.dart';
import 'package:chatting_app/Common/enums/message_enmu.dart';
import 'package:chatting_app/Common/utils/functions.dart';
import 'package:chatting_app/features/chat/controller/chat_controller.dart';
import 'package:chatting_app/features/chat/repository/chat_repository.dart';
import 'package:chatting_app/features/chat/screens/widgets/my_message_card.dart';
import 'package:chatting_app/features/chat/screens/widgets/sender_message_card.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart'; // For date formatting

class ChatList extends ConsumerStatefulWidget {
  final String receiverId;
  const ChatList({super.key, required this.receiverId});
  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messagecontroller = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messagecontroller.dispose();
  }

  void onMessageSwipe(
    String message,
    bool isMe,
    MessageEnum messageEnum,
  ) {
    // print("function call");
    ref.read(messageReplyProvider.notifier).update(
          (state) => MessageReply(
            message,
            isMe,
            messageEnum,
          ),
        );
  }

  MessageEnum messageEnumFromString(String value) {
    return MessageEnum.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => MessageEnum.text);
  }

  void testing() {}
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ref.watch(chatcontroller).contactmessages(widget.receiverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }
        final dayChats = snapshot.data!;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          messagecontroller.jumpTo(messagecontroller.position.maxScrollExtent);
        });
        return ListView.builder(
            controller: messagecontroller,
            itemCount: dayChats.length,
            itemBuilder: (context, index) {
              final dayChat = dayChats[index];
              final List<dynamic> messages = dayChat['messages'] ?? [];
              // print(dayChat['date']);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: TextButton(
                          onPressed: () => updateChatIsVanish(
                              FirebaseAuth.instance.currentUser!.uid,
                              widget.receiverId,
                              convertTimestampToDateString(dayChat['date']),
                              !dayChat['isvanish']),
                          child: Text(getDate(dayChat['date'])))),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (context, messageIndex) {
                      final message = messages[messageIndex];
                      final bool isMe = message['senderId'] ==
                          FirebaseAuth.instance.currentUser!.uid;
                      final String formattedTime = DateFormat('hh:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              message['timeSent']));

                      if (!dayChat['isvanish']) {
                        if (!message['isSeen'] &&
                            widget.receiverId ==
                                FirebaseAuth.instance.currentUser!.uid) {
                          ref.watch(chatcontroller).setSeen(
                              context, widget.receiverId, message['messageId']);
                        }
                        if (isMe) {
                          return MyMessageCard(
                            message: message['text'],
                            date: formattedTime.toString(),
                            type: messageEnumFromString(message['type']),
                            repliedMessageType: messageEnumFromString(
                                message['repliedMessageType']),
                            username: message['repliedTo'],
                            repliedText: message['repliedMessage'],
                            onLeftSwipe: () => onMessageSwipe(
                              message['text'],
                              true,
                              message['type'],
                            ),

                            //messages[0]['time'].toString(),
                          );
                        }
                        return SenderMessageCard(
                          message: message['text'],
                          date: formattedTime.toString(),
                          type: messageEnumFromString(message['type']),
                          repliedMessageType: messageEnumFromString(
                              message['repliedMessageType']),
                          username: message['repliedTo'],
                          repliedText: message['repliedMessage'],
                          onrightswip: () => onMessageSwipe(
                            message['text'],
                            false,
                            message['type'],
                          ),

                          //messages[index]['time'].toString(),
                        );
                      }
                      return null;
                    },
                  ),
                ],
              );
            });
      },
    );
  }
}
