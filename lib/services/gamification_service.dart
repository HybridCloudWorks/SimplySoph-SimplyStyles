import 'package:cloud_firestore/cloud_firestore.dart';

class GamificationService {
  final FirebaseFirestore _firestore;

  GamificationService(this._firestore);

  Future<void> awardPoints(String userId, int points) async {
    final userRef = _firestore.collection('users').doc(userId);

    // Use a transaction to ensure atomic updates
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentPoints = snapshot.data()?['points'] ?? 0;
      transaction.update(userRef, {'points': currentPoints + points});
    });
  }

  Future<void> awardBadge(String userId, String badge) async {
    await _firestore.collection('users').doc(userId).collection('badges').doc(badge).set({
      'awardedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<int> getPoints(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['points'] ?? 0;
  }
}
