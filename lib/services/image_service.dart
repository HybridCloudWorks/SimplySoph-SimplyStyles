import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
const int _thumbnailSize = 300;
const int _thumbnailQuality = 85;

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Upload clothing image and create thumbnail
  Future<Map<String, String>> uploadClothingImage({
    required String userId,
    required String imagePath,
  }) async {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    if (imagePath.isEmpty) throw ArgumentError('imagePath cannot be empty');

    try {
      final itemId = _uuid.v4();
      Uint8List imageBytes;

      // Platform-specific file reading
      if (kIsWeb) {
        // Web: imagePath is actually a blob URL or we need bytes directly
        throw UnimplementedError('Web upload requires bytes, not file path');
      } else {
        final file = File(imagePath);
        if (!await file.exists()) {
          throw ArgumentError('File does not exist: $imagePath');
        }
        imageBytes = await file.readAsBytes();
      }

      // Validate file size
      if (imageBytes.length > _maxFileSizeBytes) {
        throw Exception('File size exceeds 10MB limit');
      }

      // Upload original
      final originalRef = _storage.ref('users/$userId/wardrobe/original/$itemId.jpg');
      await originalRef.putData(imageBytes);
      final originalUrl = await originalRef.getDownloadURL();

      // Create and upload thumbnail
      final thumbnailUrl = await _createAndUploadThumbnail(
        imageBytes: imageBytes,
        userId: userId,
        itemId: itemId,
      );

      return {
        'original': originalUrl,
        'thumbnail': thumbnailUrl,
        'itemId': itemId, // Return itemId for deletion
      };
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload from bytes (web-compatible)
  Future<Map<String, String>> uploadClothingImageBytes({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    if (imageBytes.isEmpty) throw ArgumentError('imageBytes cannot be empty');

    // Validate file size
    if (imageBytes.length > _maxFileSizeBytes) {
      throw Exception('File size exceeds 10MB limit');
    }

    try {
      final itemId = _uuid.v4();

      // Upload original
      final originalRef = _storage.ref('users/$userId/wardrobe/original/$itemId.jpg');
      await originalRef.putData(imageBytes);
      final originalUrl = await originalRef.getDownloadURL();

      // Create and upload thumbnail
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

    final thumbnailRef = _storage.ref('users/$userId/wardrobe/thumbnails/${itemId}_thumb.jpg');
    await thumbnailRef.putData(Uint8List.fromList(thumbnailBytes));
    return await thumbnailRef.getDownloadURL();
  }

  /// Delete clothing image and thumbnail using storage itemId
  Future<void> deleteClothingImage(String userId, String storageItemId) async {
    if (userId.isEmpty || storageItemId.isEmpty) return;

    try {
      await _storage.ref('users/$userId/wardrobe/original/$storageItemId.jpg').delete();
      await _storage.ref('users/$userId/wardrobe/thumbnails/${storageItemId}_thumb.jpg').delete();
    } catch (e) {
      debugPrint('Error deleting image: $e');
      // Don't rethrow - image might not exist
    }
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture({
    required String userId,
    required String imagePath,
  }) async {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');

    final file = File(imagePath);
    final ref = _storage.ref('users/$userId/profile/avatar.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Delete profile picture
  Future<void> deleteProfilePicture(String userId) async {
    if (userId.isEmpty) return;

    try {
      await _storage.ref('users/$userId/profile/avatar.jpg').delete();
    } catch (e) {
      debugPrint('Error deleting profile picture: $e');
    }
  }
}
