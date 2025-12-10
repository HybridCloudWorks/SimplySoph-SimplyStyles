import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/clothing_item.dart';
import 'firestore_service.dart';
import 'image_service.dart';
import 'email_service.dart';

const List<String> _validCategories = ['top', 'bottom', 'dress', 'shoes', 'accessory'];

class WardrobeService {
  final FirestoreService _firestoreService;
  final ImageService _imageService;

  WardrobeService({
    required FirestoreService firestoreService,
    required ImageService imageService,
  })  : _firestoreService = firestoreService,
        _imageService = imageService;

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
      throw ArgumentError('Invalid category: $category. Must be one of $_validCategories');
    }

    String? storageItemId;
    String? docId;

    try {
      // Upload image
      final imageUrls = await _imageService.uploadClothingImage(
        userId: userId,
        imageBytes: imageBytes,
      );
      storageItemId = imageUrls['itemId'];

      // Create item
      final item = ClothingItem(
        id: '',
        userId: userId,
        imageUrl: imageUrls['original']!,
        thumbnailUrl: imageUrls['thumbnail']!,
        category: category,
        color: '#000000',
        colors: [],
        brand: brand ?? '',
        msrp: msrp ?? 0,
        styleTag: 'casual',
        styleTags: [],
        personaIds: [],
        scanMethod: 'upload',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      docId = await _firestoreService.addClothingItem(item);

      // Update item with storage itemId for future deletion
      await _firestoreService.updateClothingItem(docId, {
        'storageItemId': storageItemId,
      });

      // Check if this is user's first item
      final itemCount = await getItemCount(userId);
      if (itemCount == 1) {
        final emailService = EmailService();
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        final email = userDoc.data()?['email'] as String?;
        if (email != null) {
          await emailService.sendFirstItemEmail(userId, email);
        }
      }

      return docId;
    } catch (e) {
      // Rollback: delete uploaded images if Firestore write failed
      if (storageItemId != null && docId == null) {
        debugPrint('Rolling back image upload due to Firestore error');
        await _imageService.deleteClothingImage(userId, storageItemId);
      }
      rethrow;
    }
  }

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

    final item = await _firestoreService.getClothingItem(itemId);
    if (item == null) return;

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
    });
  }
}
