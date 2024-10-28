import 'dart:io';

import 'package:chatting_app/Common/enums/message_enmu.dart';
import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/features/chat/controller/chat_controller.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String receiveruserid;
  const BottomChatField({
    required this.receiveruserid,
    super.key,
  });

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isshowsendbutton = false;
  final TextEditingController _messageControlller = TextEditingController();

  void sendTextMessage() async {
    // print(" send textfunctioncall");
    if (isshowsendbutton) {
      ref.read(chatcontroller).sendMessage(
          context, _messageControlller.text.trim(), widget.receiveruserid);
      setState(() {
        _messageControlller.text = '';
      });
    }
  }

  void sendFileMessage(
    File file,
    MessageEnum messageEnum,
  ) {
    ref
        .read(chatcontroller)
        .sendfileMessage(context, file, widget.receiveruserid, messageEnum);
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {}
    sendFileMessage(image!, MessageEnum.image);
  }

  @override
  void dispose() {
    super.dispose();
    _messageControlller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _messageControlller,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      isshowsendbutton = true;
                    });
                  } else {
                    setState(() {
                      isshowsendbutton = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromRGBO(31, 44, 52, 1),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.emoji_emotions,
                              color: Colors.grey,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.gif,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: selectImage,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  hintText: 'Type a message!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 2, right: 2),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF128C7E),
                radius: 25,
                child: GestureDetector(
                  onTap: () => sendTextMessage(),
                  child: Icon(
                    isshowsendbutton ? Icons.send : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 310,
          child: EmojiPicker(
            onEmojiSelected: ((category, emoji) {
              setState(() {
                _messageControlller.text =
                    _messageControlller.text + emoji.emoji;
              });
            }),
          ),
        )
      ],
    );
  }
}
