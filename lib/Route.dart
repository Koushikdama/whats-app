import 'package:chatting_app/Common/Screen/Error.dart';
import 'package:chatting_app/User_info/Screen/private_Screen.dart';
import 'package:chatting_app/User_info/Screen/user_details.dart';
import 'package:chatting_app/auth/select_contacts/screens/select_contact_screen.dart';
import 'package:chatting_app/features/chat/screens/mobile_chat_screen.dart';

import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case UserDetails.routeName:
      return MaterialPageRoute(builder: (context) => const UserDetails());
    case PrivateSetting.routeName:

      // print("ssss${ststus}");
      return MaterialPageRoute(builder: (context) => const PrivateSetting());
    case SelectContactPage.routeName:
      return MaterialPageRoute(builder: (context) => SelectContactPage());
    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      return MaterialPageRoute(
          builder: (context) => MobileChatScreen(
                name: name,
                uid: uid,
              ));

    default:
      return MaterialPageRoute(
          builder: (context) => ErrorScreen(
                error: "NO PAGE OCCUR",
              ));
  }
}
