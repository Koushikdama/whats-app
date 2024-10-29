import 'package:chatting_app/colors.dart';
import 'package:chatting_app/features/chat/screens/widgets/display_image_text_gif.dart';
import 'package:flutter/material.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard(
      {super.key,
      required this.message,
      required this.date,
      required this.type});
  final String message;
  final String date;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: senderMessageColor,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                  padding: type == 'text'
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
                  child: DisplayTextImageGIF(message: message, type: type)),
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
    );
  }
}
