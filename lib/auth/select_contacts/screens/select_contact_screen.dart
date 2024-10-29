import 'package:chatting_app/auth/select_contacts/Model/contact_users.dart';
import 'package:chatting_app/auth/select_contacts/controller/select_Contact_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectContactPage extends ConsumerWidget {
  static const String routeName = "/selectcontact-screen";

  const SelectContactPage({super.key});

  void selectcontact(
      WidgetRef ref, Contacts selectedcontact, BuildContext context) {
    ref
        .read(selectContactControllerProvidercontacts)
        .selectContact(selectedcontact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the Future directly from the provider
    final contactsFuture = ref.watch(getContactsProvidercontacts.future);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: FutureBuilder<List<Contacts>>(
        future: contactsFuture, // Set the Future here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No contacts found'));
          } else {
            final contacts = snapshot.data!;
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
                        contact.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                      leading: contact.profilepic == null
                          ? null
                          : CircleAvatar(
                              backgroundImage: NetworkImage(contact.profilepic),
                              radius: 30,
                            ),
                      subtitle: contact.phonenumber.isNotEmpty
                          ? Text(contact.phonenumber)
                          : null,
                      onTap: () => selectcontact(ref, contact, context),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
