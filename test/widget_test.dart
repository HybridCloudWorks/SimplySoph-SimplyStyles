import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simplystyles/main.dart';
import 'package:simplystyles/auth/auth_service.dart';
import 'package:simplystyles/services/database_service.dart';
import 'package:simplystyles/services/social_service.dart';

class MockAuthService extends Mock implements AuthService {
  @override
  Stream<User?> get authStateChanges => Stream.value(null);
  @override
  Future<void> initializeAuth() async { return; }
}
class MockDatabaseService extends Mock implements DatabaseService {}
class MockSocialService extends Mock implements SocialService {}

void main() {
  testWidgets('App smoke test (logged out)', (WidgetTester tester) async {
    // 1. Pump the app
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: MockAuthService()),
          Provider<DatabaseService>.value(value: MockDatabaseService()),
          Provider<SocialService>.value(value: MockSocialService()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 2. Handle Onboarding (Click "Get Started" if present)
    final getStartedBtn = find.text('Get Started');
    if (getStartedBtn.evaluate().isNotEmpty) {
      await tester.tap(getStartedBtn);
      await tester.pumpAndSettle();
    }

    // 3. Verify we are on the Login Screen
    // We check for ANY TextField (Email or Password input) to confirm the screen loaded.
    expect(find.byType(TextField), findsAtLeastNWidgets(1));
  });
}