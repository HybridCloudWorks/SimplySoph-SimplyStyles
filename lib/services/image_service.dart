import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
const int _thumbnailSize = 300;
const int _thumbnailQuality = 85;

class ImageService {
  final Uuid _uuid = const Uuid();

  /// Upload clothing image from bytes
  /// Performs client-side resizing for immediate thumbnail availability.
  /// Accepts [customItemId] to allow pre-generation of IDs.
  Future<Map<String, String>> uploadClothingImage({
    required String userId,
    required Uint8List imageBytes,
    String? customItemId,
  }) async {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    if (imageBytes.isEmpty) throw ArgumentError('imageBytes cannot be empty');

    // Check authentication
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User must be authenticated to upload images');
    }
    if (currentUser.uid != userId) {
      throw Exception('User can only upload to their own storage');
    }

    // Force token refresh
    await currentUser.getIdToken(true);

    // Validate file size
    if (imageBytes.length > _maxFileSizeBytes) {
      throw Exception('File size exceeds 10MB limit');
    }

    try {
      final itemId = customItemId ?? _uuid.v4();

      // Upload original with metadata
      final originalRef = FirebaseStorage.instance
          .ref('users/$userId/wardrobe/original/$itemId.jpg');
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      await originalRef.putData(imageBytes, metadata);
      final originalUrl = await originalRef.getDownloadURL();

      // Create and upload thumbnail immediately (Client-side)
      // This ensures we have a valid URL with token immediately, avoiding race conditions
      // with server-side extensions.
      final thumbnailUrl = await _createAndUploadThumbnail(
        imageBytes: imageBytes,
        userId: userId,
        itemId: itemId,
      );

      return {
        'original': originalUrl,
        'thumbnail': thumbnailUrl,
        'itemId': itemId,
      };
    } catch (e) {
      debugPrint('Error uploading image bytes: $e');
      rethrow;
    }
  }

  /// Create thumbnail and upload
  Future<String> _createAndUploadThumbnail({
    required Uint8List imageBytes,
    required String userId,
    required String itemId,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    // Resize maintaining aspect ratio
    final thumbnail = img.copyResize(
      image,
      width: image.width > image.height ? _thumbnailSize : null,
      height: image.height >= image.width ? _thumbnailSize : null,
    );
    final thumbnailBytes = img.encodeJpg(thumbnail, quality: _thumbnailQuality);

    final thumbnailRef = FirebaseStorage.instance
        .ref('users/$userId/wardrobe/thumbnails/${itemId}_thumb.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    await thumbnailRef.putData(Uint8List.fromList(thumbnailBytes), metadata);
    return await thumbnailRef.getDownloadURL();
  }

  /// Delete clothing image and thumbnail using storage itemId
  Future<void> deleteClothingImage(String userId, String storageItemId) async {
    if (userId.isEmpty || storageItemId.isEmpty) return;

    try {
      await FirebaseStorage.instance
          .ref('users/$userId/wardrobe/original/$storageItemId.jpg')
          .delete();
      await FirebaseStorage.instance
          .ref('users/$userId/wardrobe/thumbnails/${storageItemId}_thumb.jpg')
          .delete();
    } catch (e) {
      debugPrint('Error deleting image: $e');
      // Don't rethrow - image might not exist or already be deleted
    }
  }

  /// Upload profile picture from bytes
  Future<String> uploadProfilePicture({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    if (imageBytes.isEmpty) throw ArgumentError('imageBytes cannot be empty');

    if (imageBytes.length > _maxFileSizeBytes) {
      throw Exception('File size exceeds 10MB limit');
    }

    final ref =
        FirebaseStorage.instance.ref('users/$userId/profile/avatar.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    await ref.putData(imageBytes, metadata);
    return await ref.getDownloadURL();
  }

  /// Delete profile picture
  Future<void> deleteProfilePicture(String userId) async {
    if (userId.isEmpty) return;

    try {
      await FirebaseStorage.instance
          .ref('users/$userId/profile/avatar.jpg')
          .delete();
    } catch (e) {
      debugPrint('Error deleting profile picture: $e');
      // Ignore errors if profile picture doesn't exist
    }
  }

  /// Get a fresh download URL for an image (handles token refresh automatically)
  /// [imagePath] should be relative to "users/$userId/".
  Future<String?> getFreshDownloadUrl(String userId, String imagePath) async {
    try {
      // Check authentication
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        debugPrint('User not authenticated, cannot get download URL');
        return null;
      }

      // Force token refresh to ensure valid download URLs
      await currentUser.getIdToken(true);

      final ref = FirebaseStorage.instance.ref('users/$userId/$imagePath');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error getting download URL for $imagePath: $e');
      return null;
    }
  }
}
