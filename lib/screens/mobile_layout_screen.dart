import 'package:chatting_app/Common/utils/showAlert.dart';
import 'package:chatting_app/Common/utils/showSnack.dart';
import 'package:chatting_app/User_info/Controller/userController.dart';
import 'package:chatting_app/auth/select_contacts/screens/select_contact_screen.dart';
import 'package:chatting_app/colors.dart';
import 'package:chatting_app/features/chat/controller/chat_controller.dart';
import 'package:chatting_app/features/chat/screens/contacts_list.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({super.key});
  static const String routeName = "/starting-page";

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver {
  late bool status = false; // Initialize status

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        ref.read(authControllerProvider).setUserState(false);
        setState(() {
          status = false;
        });
        break;
      default:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  void change(BuildContext context) {
    // Check the current status before toggling
    if (!status) {
      showAlertDialogpassword(context, (String password) async {
        if (password.isNotEmpty) {
          // If password is not empty, perform the necessary actions
          bool isCorrect =
              await ref.watch(authControllerProvider).iscorrect(password);

          if (isCorrect) {
            // Use the password as needed

            // Call the chat contact method with the updated status
            ref.watch(chatcontroller).chatContact(status: !status);
            ref.watch(authControllerProvider).setprivatestate(!status);

            // Toggle the status
            setState(() {
              status = !status; // Change the status to true
            });
          } else {
            // Handle incorrect password
            showSnackBar(context, "Incorrect password.");
          }
        } else {
          // Handle the case when the password is empty (user clicked cancel)
          print("User canceled the operation or did not enter a password.");
        }
      });
    } else {
      // If status is true, just toggle the status without showing the dialog
      ref.watch(chatcontroller).chatContact(status: status);
      ref.watch(authControllerProvider).setprivatestate(!status);
      setState(() {
        status = !status; // Toggle the status
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appBarColor,
          centerTitle: false,
          title: InkWell(
            onDoubleTap: () => change(context),
            child: Text(
              'WhatsApp',
              style: TextStyle(
                fontSize: 20,
                color: status
                    ? tabColor
                    : Colors.grey, // Change color based on status
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            indicatorColor: tabColor,
            indicatorWeight: 4,
            labelColor: tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(
                text: 'CHATS',
              ),
              Tab(
                text: 'STATUS',
              ),
              Tab(
                text: 'CALLS',
              ),
            ],
          ),
        ),
        body: ContactsList(status),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, SelectContactPage.routeName);
          },
          backgroundColor: tabColor,
          child: const Icon(
            Icons.comment,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
