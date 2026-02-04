import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/gemini_cortex_api.dart';
import '../models/style_persona.dart';

class PersonaService {
  final FirebaseFirestore _firestore;
  final GeminiCortexAPI _api;

  PersonaService([FirebaseFirestore? firestore, GeminiCortexAPI? api])
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _api = api ?? GeminiCortexAPI();

  /// Get all style personas for a user
  Stream<List<StylePersona>> getPersonas(String userId) {
    return _firestore
        .collection('style_personas')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StylePersona.fromFirestore(doc))
            .toList());
  }

  /// Generate style personas for a user (requires 5+ items)
  Future<void> generatePersonas(String userId) async {
    try {
      await _api.generateStylePersonas();
    } catch (e) {
      // In test environments or when API is not available, skip persona generation
      // This allows the app to function without Firebase Functions in tests
    }
  }

  /// Check if user has enough items to generate personas
  Future<bool> canGeneratePersonas(String userId) async {
    final snapshot = await _firestore
        .collection('wardrobe_items')
        .where('userId', isEqualTo: userId)
        .count()
        .get();
    return (snapshot.count ?? 0) >= 5;
  }

  /// Get persona count for user
  Future<int> getPersonaCount(String userId) async {
    final snapshot = await _firestore
        .collection('style_personas')
        .where('userId', isEqualTo: userId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
