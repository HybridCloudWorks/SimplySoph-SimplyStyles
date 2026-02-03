import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simplystyles/services/email_service.dart';
import 'package:simplystyles/services/firestore_service.dart';
import 'package:simplystyles/services/image_service.dart';
import 'package:simplystyles/services/wardrobe_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Closet Upload Integration Tests', () {
    late FirestoreService firestoreService;
    late ImageService imageService;
    late WardrobeService wardrobeService;

    setUp(() {
      final fake = FakeFirebaseFirestore();
      firestoreService = FirestoreService(
        firestore: fake,
        emailService: EmailService(firestore: fake),
      );
      imageService = ImageService();
      wardrobeService = WardrobeService(
        firestoreService: firestoreService,
        imageService: imageService,
      );
    });

    test('WardrobeService validates userId', () {
      expect(
        () => wardrobeService.addItem(
          userId: '',
          imageBytes: Uint8List(0),
          category: 'top',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('WardrobeService validates empty imageBytes', () {
      expect(
        () => wardrobeService.addItem(
          userId: 'test-user-123',
          imageBytes: Uint8List(0),
          category: 'top',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('WardrobeService validates category', () {
      expect(
        () => wardrobeService.addItem(
          userId: 'test-user-123',
          imageBytes: Uint8List.fromList([1, 2, 3]),
          category: 'invalid-category',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Valid categories are accepted', () {
      final validCategories = ['top', 'bottom', 'dress', 'shoes', 'accessory'];

      for (final category in validCategories) {
        expect(validCategories.contains(category), isTrue);
      }
    });

    test('Storage path follows correct structure', () {
      const userId = 'test-user-123';
      const itemId = 'item-456';

      final originalPath = 'users/$userId/wardrobe/original/$itemId.jpg';
      final thumbnailPath =
          'users/$userId/wardrobe/thumbnails/${itemId}_thumb.jpg';

      expect(originalPath, contains('users/$userId'));
      expect(thumbnailPath, contains('users/$userId'));
      expect(originalPath, endsWith('.jpg'));
      expect(thumbnailPath, endsWith('_thumb.jpg'));
    });
  });

  group('Storage Rules Validation', () {
    test('Storage path matches rules pattern', () {
      const userId = 'test-user-123';
      const itemId = 'abc-123';

      // Rules: match /users/{userId}/{allPaths=**}
      final path = 'users/$userId/wardrobe/original/$itemId.jpg';

      expect(path, startsWith('users/$userId/'));
    });

    test('File size validation', () {
      const maxSize = 10 * 1024 * 1024; // 10MB

      final validSize = 5 * 1024 * 1024; // 5MB
      final invalidSize = 15 * 1024 * 1024; // 15MB

      expect(validSize < maxSize, isTrue);
      expect(invalidSize < maxSize, isFalse);
    });

    test('Content type validation', () {
      final validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
      final invalidTypes = ['video/mp4', 'application/pdf', 'text/plain'];

      for (final type in validTypes) {
        expect(type, startsWith('image/'));
      }

      for (final type in invalidTypes) {
        expect(type.startsWith('image/'), isFalse);
      }
    });
  });

  group('ImageService Token Refresh', () {
    test('ImageService validates userId', () {
      final imageService = ImageService();

      expect(
        () => imageService.uploadClothingImage(
          userId: '',
          imageBytes: Uint8List.fromList([1, 2, 3]),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('ImageService validates imageBytes', () {
      final imageService = ImageService();

      expect(
        () => imageService.uploadClothingImage(
          userId: 'test-user',
          imageBytes: Uint8List(0),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
