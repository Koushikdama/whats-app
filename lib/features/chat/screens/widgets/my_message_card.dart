import 'package:flutter/material.dart';
import 'package:chatting_app/colors.dart';
import 'package:chatting_app/features/chat/screens/widgets/display_image_text_gif.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatting_app/Common/Providers/messsage_reply_provider.dart';
import 'package:chatting_app/Common/enums/message_enmu.dart';

class MyMessageCard extends ConsumerWidget {
  final String message;
  final String date;
  final MessageEnum type; // Changed to MessageEnum
  final VoidCallback onLeftSwipe;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;

  const MyMessageCard({
    super.key,
    required this.message,
    required this.date,
    required this.type,
    required this.onLeftSwipe,
    required this.repliedText,
    required this.username,
    required this.repliedMessageType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print("message type ${type.name}");
    final isReplying = repliedText.isNotEmpty;
    // print("testing ${this.repliedMessageType}${this.repliedText} ");
    return SwipeTo(
      onLeftSwipe: (_) {
        ref.read(messageReplyProvider.notifier).state = MessageReply(
          message, // Set this based on the actual sender
          true,
          type, // Pass the MessageEnum directly
        );
        // print("onLeftSwipe ${message}");
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: messageColor,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                  padding: type == MessageEnum.text // Updated to MessageEnum
                      ? EdgeInsets.only(
                          left: message.length > date.length
                              ? 20
                              : (date.length * 6).toDouble(),
                          right: 30,
                          top: 3,
                          bottom: 18,
                        )
                      : const EdgeInsets.only(
                          left: 2,
                          top: 1,
                          right: 2,
                          bottom: 25,
                        ),
                  child: Column(
                    children: [
                      if (isReplying) ...[
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height:
                              repliedMessageType.name != 'text' ? 100 : null,
                          width: repliedMessageType.name != 'text' ? 100 : null,
                          //padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: backgroundColor.withOpacity(0.5),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(
                                3,
                              ),
                            ),
                          ),
                          child: DisplayTextImageGIF(
                            message: repliedText,
                            type: repliedMessageType.name,
                          ),
                        ),
                        const SizedBox(height: 9),
                      ],
                      DisplayTextImageGIF(message: message, type: type.name),
                    ],
                  ), // Make sure this is correctly handled
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Row(
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.done_all,
                        size: 20,
                        color: Colors.white60,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
