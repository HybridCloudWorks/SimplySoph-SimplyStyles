import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/clothing_item.dart';
import '../models/style_persona.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get personalized recommendations for a user
  Future<List<Map<String, dynamic>>> getPersonalizedRecommendations(
      String userId) async {
    // Get user's personas
    final personasSnapshot = await _firestore
        .collection('style_personas')
        .where('userId', isEqualTo: userId)
        .get();

    if (personasSnapshot.docs.isEmpty) {
      return _getDefaultRecommendations();
    }

    final personas = personasSnapshot.docs
        .map((doc) => StylePersona.fromFirestore(doc))
        .toList();

    // Get user's wardrobe items
    final wardrobeSnapshot = await _firestore
        .collection('wardrobe_items')
        .where('userId', isEqualTo: userId)
        .get();

    final wardrobeItems = wardrobeSnapshot.docs
        .map((doc) => ClothingItem.fromFirestore(doc))
        .toList();

    // Generate recommendations based on personas and existing items
    return _generateRecommendations(personas, wardrobeItems);
  }

  /// Get recommendations by persona
  Future<List<Map<String, dynamic>>> getRecommendationsByPersona(
      String userId, String personaId) async {
    final personaDoc =
        await _firestore.collection('style_personas').doc(personaId).get();

    if (!personaDoc.exists) {
      return [];
    }

    final persona = StylePersona.fromFirestore(personaDoc);
    return _generateRecommendationsForPersona(persona);
  }

  /// Get trending recommendations
  Future<List<Map<String, dynamic>>> getTrendingRecommendations() async {
    // Get trending items from Firestore (populated by daily job)
    final trendsSnapshot = await _firestore
        .collection('trends')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    return trendsSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Trending Item',
        'description': data['description'] ?? '',
        'brand': 'Trending Brand',
        'price': 89.99,
        'matchScore': 85 + (doc.id.hashCode % 10), // Mock score
        'imageUrl': '', // Would need actual product images
        'isTrending': true,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _getDefaultRecommendations() {
    return [
      {
        'id': 'default1',
        'name': 'Classic White Tee',
        'brand': 'Essential Basics',
        'price': 29.99,
        'matchScore': 75,
        'description': 'A wardrobe essential',
      },
      {
        'id': 'default2',
        'name': 'Blue Jeans',
        'brand': 'Denim Co',
        'price': 79.99,
        'matchScore': 70,
        'description': 'Comfortable and versatile',
      },
      {
        'id': 'default3',
        'name': 'Black Dress',
        'brand': 'Elegant Wear',
        'price': 129.99,
        'matchScore': 65,
        'description': 'Perfect for any occasion',
      },
    ];
  }

  List<Map<String, dynamic>> _generateRecommendations(
      List<StylePersona> personas, List<ClothingItem> wardrobeItems) {
    final recommendations = <Map<String, dynamic>>[];

    for (final persona in personas) {
      // Generate recommendations based on persona key pieces and color palette
      for (final keyPiece in persona.keyPieces) {
        final recommendation = {
          'id': '${persona.id}_$keyPiece',
          'name': _getItemNameFromKeyPiece(keyPiece),
          'brand': _getBrandFromPersona(persona),
          'price': _calculatePrice(persona, keyPiece),
          'matchScore': 90 + (persona.id.hashCode % 10),
          'personaName': persona.name,
          'description': 'Matches your ${persona.name} style',
        };
        recommendations.add(recommendation);
      }
    }

    return recommendations.take(10).toList();
  }

  List<Map<String, dynamic>> _generateRecommendationsForPersona(
      StylePersona persona) {
    return persona.keyPieces.map((keyPiece) {
      return {
        'id': '${persona.id}_$keyPiece',
        'name': _getItemNameFromKeyPiece(keyPiece),
        'brand': _getBrandFromPersona(persona),
        'price': _calculatePrice(persona, keyPiece),
        'matchScore': 95,
        'description': 'Perfect for ${persona.name} style',
      };
    }).toList();
  }

  String _getItemNameFromKeyPiece(String keyPiece) {
    final itemNames = {
      'jeans': 'Premium Denim Jeans',
      'white tee': 'Organic Cotton Tee',
      'sneakers': 'Classic Canvas Sneakers',
      'blazer': 'Tailored Blazer',
      'dress': 'Flowy Midi Dress',
      'hoodie': 'Cozy Hoodie',
      'leggings': 'High-Waisted Leggings',
      'boots': 'Ankle Boots',
    };
    return itemNames[keyPiece.toLowerCase()] ?? '$keyPiece Item';
  }

  String _getBrandFromPersona(StylePersona persona) {
    // Mock brand selection based on persona
    final brands = [
      'StyleCo',
      'Fashion Forward',
      'Trendy Threads',
      'Classic Wear'
    ];
    return brands[persona.id.hashCode % brands.length];
  }

  double _calculatePrice(StylePersona persona, String keyPiece) {
    // Mock pricing logic
    final basePrices = {
      'jeans': 89.99,
      'white tee': 29.99,
      'sneakers': 79.99,
      'blazer': 149.99,
      'dress': 119.99,
      'hoodie': 59.99,
      'leggings': 49.99,
      'boots': 129.99,
    };
    return basePrices[keyPiece.toLowerCase()] ?? 69.99;
  }
}
