import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/clothing_item.dart';
import '../models/style_persona.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Wardrobe Items
  Future<String> addClothingItem(ClothingItem item) async {
    final docRef = await _firestore.collection('wardrobe_items').add(item.toFirestore());
    return docRef.id;
  }

  Future<void> updateClothingItem(String itemId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('wardrobe_items').doc(itemId).update(updates);
  }

  Future<void> deleteClothingItem(String itemId) async {
    await _firestore.collection('wardrobe_items').doc(itemId).delete();
  }

  Stream<List<ClothingItem>> getWardrobeItems(String userId) {
    return _firestore
        .collection('wardrobe_items')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ClothingItem.fromFirestore(doc)).toList());
  }

  Future<ClothingItem?> getClothingItem(String itemId) async {
    DocumentSnapshot doc = await _firestore.collection('wardrobe_items').doc(itemId).get();
    if (doc.exists) {
      return ClothingItem.fromFirestore(doc);
    }
    return null;
  }

  // Style Personas
  Future<void> addStylePersona(StylePersona persona) async {
    await _firestore.collection('style_personas').add(persona.toFirestore());
  }

  Future<void> updateStylePersona(String personaId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('style_personas').doc(personaId).update(updates);
  }

  Future<void> deleteStylePersona(String personaId) async {
    await _firestore.collection('style_personas').doc(personaId).delete();
  }

  Stream<List<StylePersona>> getStylePersonas(String userId) {
    return _firestore
        .collection('style_personas')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => StylePersona.fromFirestore(doc)).toList());
  }

  Future<StylePersona?> getStylePersona(String personaId) async {
    DocumentSnapshot doc = await _firestore.collection('style_personas').doc(personaId).get();
    if (doc.exists) {
      return StylePersona.fromFirestore(doc);
    }
    return null;
  }

  // User Profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    await _firestore.collection('users').doc(userId).update(updates);
  }

  /// Saves the user's onboarding choices to Firestore and
  /// marks their onboarding as complete.
  Future<void> saveAndCompleteOnboarding({
    required String uid,
    required String? style,
    required List<String> colors,
  }) async {
    try {
      // We use 'update' here because we're adding fields to an
      // existing user document that was created at sign-up.
      await _firestore.collection('users').doc(uid).update({
        'stylePreference': style,
        'favoriteColors': colors,
        // ... (add any other fields you collected)
        
        // This is the magic flag our AuthWrapper is listening for!
        'onboardingComplete': true, 
      });
    } catch (e) {
      // Handle errors
      debugPrint('Error saving onboarding data: $e');
      rethrow; // Re-throw the error so the UI can catch it
    }
  }
}
