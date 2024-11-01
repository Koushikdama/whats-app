import 'package:chatting_app/Common/enums/message_enmu.dart';
import 'package:chatting_app/colors.dart';
import 'package:chatting_app/features/chat/screens/widgets/display_image_text_gif.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard(
      {super.key,
      required this.message,
      required this.date,
      required this.type,
      required this.onrightswip,
      required this.repliedText,
      required this.username,
      required this.repliedMessageType});
  final String message;
  final String date;
  final MessageEnum type; // Changed to MessageEnum
  final VoidCallback onrightswip;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;
    return SwipeTo(
      onRightSwipe: (_) => onrightswip,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: senderMessageColor,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                    padding: type.name == 'text'
                        ? EdgeInsets.only(
                            left: message.length > date.length
                                ? 20
                                : ((date.length).toDouble()) * 6,
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: backgroundColor.withOpacity(0.5),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(
                                  5,
                                ),
                              ),
                            ),
                            child: DisplayTextImageGIF(
                              message: repliedText,
                              type: repliedMessageType.name,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        DisplayTextImageGIF(message: message, type: type.name),
                      ],
                    )),
                Positioned(
                  bottom: 2,
                  right: 10,
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
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
