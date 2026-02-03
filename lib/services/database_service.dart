import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore;

  DatabaseService({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Returns a real-time stream of the user's document.
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Updates the user's document to mark onboarding as complete.
  Future<void> completeOnboarding(String uid) {
    return _firestore.collection('users').doc(uid).update({
      'onboardingComplete': true,
    });
  }

  /// Creates a user document if it doesn't exist
  Future<void> createUserDocument(String uid, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }
}
