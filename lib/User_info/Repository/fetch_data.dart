import 'package:chatting_app/User_info/Model/UserModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController extends StateNotifier<UserProfile?> {
  UserController() : super(null);

  // Fetch user data from Firestore
  Future<UserProfile?> fetchUserData(String uid) async {
    try {
      //String uid=FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      //print('Error fetching user data: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(UserProfile userProfile) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userProfile.uid)
          .set(userProfile.toMap());
    } catch (e) {
      //print('Error updating user data: $e');
    }
  }
}

// Create a provider for UserController
final userControllerProvider =
    StateNotifierProvider<UserController, UserProfile?>((ref) {
  return UserController();
});
