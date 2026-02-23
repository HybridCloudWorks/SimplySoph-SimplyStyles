import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:simplystyles/auth/auth_service.dart';
import 'package:simplystyles/services/image_service.dart';
import 'package:simplystyles/screens/components/network_image_with_retry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

// Mock Classes
class MockAuthService extends Mock implements AuthService {
  @override
  User? get currentUser => MockUser();
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'testUser';
}

class MockImageService extends Mock implements ImageService {
  String? lastRequestedPath;

  @override
  Future<String?> getFreshDownloadUrl(String userId, String imagePath) async {
    lastRequestedPath = imagePath;
    return 'https://firebasestorage.googleapis.com/v0/b/bucket/o/fresh_url';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NetworkImageWithRetry removes prefix for getFreshDownloadUrl', (WidgetTester tester) async {
    final mockImageService = MockImageService();
    final mockAuthService = MockAuthService();

    // Construct a URL that looks like a Firebase Storage URL with the prefix
    // Encoded path: users%2FtestUser%2Fwardrobe%2Fthumbnails%2Fitem_thumb.jpg
    const originalUrl = 'https://firebasestorage.googleapis.com/v0/b/bucket/o/users%2FtestUser%2Fwardrobe%2Fthumbnails%2Fitem_thumb.jpg?alt=media';

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ImageService>.value(value: mockImageService),
          Provider<AuthService>.value(value: mockAuthService),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: NetworkImageWithRetry(
              imageUrl: originalUrl,
            ),
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Pump to process the image loading failure (Image.network fails in test)
    await tester.pump();

    // The errorBuilder should have fired.
    // It schedules a post frame callback to call _refreshUrl.
    await tester.pump(const Duration(milliseconds: 100));

    // Now verify the logic
    // Expected logic:
    // 1. URL has 'o' segment.
    // 2. Encoded path is 'users%2FtestUser%2Fwardrobe%2Fthumbnails%2Fitem_thumb.jpg'
    // 3. Decoded path is 'users/testUser/wardrobe/thumbnails/item_thumb.jpg'
    // 4. Starts with 'users/testUser/'
    // 5. Removes prefix -> 'wardrobe/thumbnails/item_thumb.jpg'
    // 6. Calls getFreshDownloadUrl('testUser', 'wardrobe/thumbnails/item_thumb.jpg')

    expect(mockImageService.lastRequestedPath, 'wardrobe/thumbnails/item_thumb.jpg');
  });
}
