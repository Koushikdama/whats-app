import 'package:chatting_app/auth/select_contacts/controller/select_contact_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectContactPage extends ConsumerWidget {
  static const String routeName = "/selectcontact-screen";

  const SelectContactPage({super.key});

  void selectcontact(
      WidgetRef ref, Contact selectedcontact, BuildContext context) {
    // print("function call");
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedcontact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsyncValue = ref.watch(getContactsProvider);
    //print(contactsAsyncValue);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      body: contactsAsyncValue.when(
        data: (contacts) {
          if (contacts.isEmpty) {
            return const Center(child: Text('No contacts found'));
          }
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return InkWell(
                onTap: () => selectcontact(ref, contact, context),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      contact.displayName,
                      style: const TextStyle(fontSize: 18),
                    ),
                    leading: contact.photo == null
                        ? null
                        : CircleAvatar(
                            backgroundImage: MemoryImage(contact.photo!),
                            radius: 30,
                          ),
                    subtitle: contact.phones.isNotEmpty
                        ? Text(contact.phones[0].number)
                        : null,
                    onTap: () => {
                      // print("contact${contact}"),
                      selectcontact(ref, contact, context)
                    }
                    // final selectContactController =
                    //     ref.read(selectContactControllerProvider);
                    // selectContactController.selectContact(contact, context);

                    ,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
