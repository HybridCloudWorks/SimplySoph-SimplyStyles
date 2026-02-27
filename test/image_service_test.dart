import 'package:flutter_test/flutter_test.dart';
import 'package:simplystyles/services/image_service.dart';

void main() {
  group('ImageService URL extraction', () {
    late ImageService imageService;

    setUp(() {
      imageService = ImageService();
    });

    test('extractRelativePathFromUrl extracts correct path', () {
      const userId = 'testUser';
      const url = 'https://firebasestorage.googleapis.com/v0/b/bucket/o/users%2FtestUser%2Fwardrobe%2Fthumbnails%2Fitem_thumb.jpg?alt=media';

      final path = imageService.extractRelativePathFromUrl(url, userId);

      expect(path, 'wardrobe/thumbnails/item_thumb.jpg');
    });

    test('extractRelativePathFromUrl returns null for invalid URL', () {
      const userId = 'testUser';
      const url = 'https://example.com/image.jpg';

      final path = imageService.extractRelativePathFromUrl(url, userId);

      expect(path, isNull);
    });

    test('extractRelativePathFromUrl returns null for non-firebase URL', () {
      const userId = 'testUser';
      const url = 'https://notfirebase.com/o/users%2FtestUser%2Fpath';

      final path = imageService.extractRelativePathFromUrl(url, userId);

      expect(path, isNull);
    });

    test('extractRelativePathFromUrl returns null if path does not start with users/userId', () {
      const userId = 'testUser';
      const url = 'https://firebasestorage.googleapis.com/v0/b/bucket/o/other%2Fpath%2Fimage.jpg';

      final path = imageService.extractRelativePathFromUrl(url, userId);

      expect(path, isNull);
    });
  });
}
