import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/clothing_item.dart';
import 'email_service.dart';
import 'firestore_service.dart';
import 'gamification_service.dart';
import 'image_service.dart';
import 'persona_service.dart';

const List<String> _validCategories = [
  'top',
  'bottom',
  'dress',
  'shoes',
  'accessory',
  'outerwear'
];

class WardrobeService {
  final FirestoreService _firestoreService;
  final ImageService _imageService;
  final GamificationService _gamificationService;
  final PersonaService _personaService;
  final EmailService _emailService;
  final Uuid _uuid = const Uuid();

  WardrobeService({
    required FirestoreService firestoreService,
    required ImageService imageService,
    required GamificationService gamificationService,
    required PersonaService personaService,
    required EmailService emailService,
  })  : _firestoreService = firestoreService,
        _imageService = imageService,
        _gamificationService = gamificationService,
        _personaService = personaService,
        _emailService = emailService;

  /// Add a new clothing item (Platform agnostic, uses bytes)
  Future<String> addItem({
    required String userId,
    required Uint8List imageBytes,
    required String category,
    String? brand,
    double? msrp,
  }) async {
    // Validation
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    if (imageBytes.isEmpty) throw ArgumentError('imageBytes cannot be empty');
    if (!_validCategories.contains(category)) {
      throw ArgumentError(
          'Invalid category: $category. Must be one of $_validCategories');
    }

    // Generate IDs upfront
    final storageItemId = _uuid.v4();
    String? docId;

    try {
      // 1. Create initial Firestore document with 'uploading' status
      final initialItem = ClothingItem(
        id: '',
        userId: userId,
        imageUrl: '', // Placeholder
        thumbnailUrl: '', // Placeholder
        category: category,
        color: '#000000',
        colors: [],
        brand: brand ?? '',
        msrp: msrp ?? 0,
        styleTag: 'casual',
        styleTags: [],
        personaIds: [],
        scanMethod: 'upload',
        status: 'uploading',
        storageItemId: storageItemId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to Firestore and get the generated document ID
      final docRef = await _firestoreService.firestore.collection('wardrobe_items').add(initialItem.toFirestore());
      docId = docRef.id;

      // 2. Upload image
      final imageUrls = await _imageService.uploadClothingImage(
        userId: userId,
        imageBytes: imageBytes,
        customItemId: storageItemId,
      );

      // 3. Update document with URLs and 'analyzing' status
      await _firestoreService.updateClothingItem(docId, {
        'imageUrl': imageUrls['original'],
        'thumbnailUrl': imageUrls['thumbnail'],
        'status': 'analyzing',
      });

      // 4. Award gamification points
      await _gamificationService.awardPoints(userId, 10); // Award 10 points

      // Check if this is user's first item
      final itemCount = await getItemCount(userId);
      if (itemCount == 1) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        final email = userDoc.data()?['email'] as String?;
        if (email != null) {
          await _emailService.sendFirstItemEmail(userId, email);
          await _gamificationService.awardBadge(userId, 'first_item'); // Award 'First Item' badge
        }
      }

      // Check if we should generate personas
      final personaCount = await _personaService.getPersonaCount(userId);
      if (itemCount >= 5 && personaCount == 0) {
        try {
          _personaService.generatePersonas(userId).then((_) {
             debugPrint('Style personas generated for user $userId');
          }).catchError((e) {
             debugPrint('Failed to generate personas: $e');
          });
        }
        catch (e) {
          debugPrint('Failed to trigger persona generation: $e');
        }
      }

      return docId;
    } catch (e) {
      // Rollback
      debugPrint('Error adding item: $e');

      if (docId != null) {
        await _firestoreService.deleteClothingItem(docId);
      }

      if (storageItemId.isNotEmpty) {
        await _imageService.deleteClothingImage(userId, storageItemId);
      }
      rethrow;
    }
  }

  // ... (rest of the class is the same)
  /// Get all wardrobe items for a user
  Stream<List<ClothingItem>> getItems(String userId) {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    return _firestoreService.getWardrobeItems(userId);
  }

  /// Get a single item
  Future<ClothingItem?> getItem(String itemId) {
    if (itemId.isEmpty) throw ArgumentError('itemId cannot be empty');
    return _firestoreService.getClothingItem(itemId);
  }

  /// Update item details
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) {
    if (itemId.isEmpty) throw ArgumentError('itemId cannot be empty');
    if (updates.isEmpty) throw ArgumentError('updates cannot be empty');
    return _firestoreService.updateClothingItem(itemId, updates);
  }

  /// Delete item and its images
  Future<void> deleteItem(String itemId, String userId) async {
    if (itemId.isEmpty || userId.isEmpty) {
      throw ArgumentError('itemId and userId cannot be empty');
    }

    // Get storageItemId from item data
    final itemData = await FirebaseFirestore.instance
        .collection('wardrobe_items')
        .doc(itemId)
        .get();
    final storageItemId = itemData.data()?['storageItemId'] as String?;

    // Delete from Firestore first
    await _firestoreService.deleteClothingItem(itemId);

    // Then delete images
    if (storageItemId != null) {
      await _imageService.deleteClothingImage(userId, storageItemId);
    }
  }

  /// Get item count for user
  /// Uses efficient aggregation query.
  Future<int> getItemCount(String userId) async {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');

    final snapshot = await FirebaseFirestore.instance
        .collection('wardrobe_items')
        .where('userId', isEqualTo: userId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Update item with AI analysis results
  Future<void> updateWithAIAnalysis(
    String itemId,
    Map<String, dynamic> analysis,
  ) async {
    if (itemId.isEmpty) throw ArgumentError('itemId cannot be empty');
    if (analysis.isEmpty) throw ArgumentError('analysis cannot be empty');

    await _firestoreService.updateClothingItem(itemId, {
      'color': analysis['color'] ?? '#000000',
      'dominantColors': analysis['dominantColors'] ?? [],
      'styleTag': analysis['styleTag'] ?? 'casual',
      'tags': analysis['tags'] ?? [],
      'brand': analysis['brand'] ?? '',
      'msrp': analysis['msrp'] ?? 0,
      'status': 'completed', // Mark as completed
    });
  }
}
