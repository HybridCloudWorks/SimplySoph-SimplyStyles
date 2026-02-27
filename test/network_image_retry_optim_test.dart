import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simplystyles/screens/components/network_image_with_retry.dart';
import 'package:simplystyles/services/image_service.dart';
import 'package:simplystyles/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MockImageService extends Mock implements ImageService {}
class MockAuthService extends Mock implements AuthService {}

void main() {
  testWidgets('NetworkImageWithRetry uses CachedNetworkImage', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ImageService>(create: (_) => MockImageService()),
          Provider<AuthService>(create: (_) => MockAuthService()),
        ],
        child: MaterialApp(
          home: const NetworkImageWithRetry(
            imageUrl: 'https://example.com/image.jpg',
          ),
        ),
      ),
    );

    // Verify that CachedNetworkImage is used instead of a direct Image.network
    expect(find.byType(CachedNetworkImage), findsOneWidget);

    // In test environment, CachedNetworkImage usually resolves to a placeholder or error widget
    // depending on the network, but the important part is that the wrapper widget is present.
  });
}
