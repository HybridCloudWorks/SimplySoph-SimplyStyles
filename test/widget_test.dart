import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:simplystyles/auth/auth_service.dart';
import 'package:simplystyles/main.dart';
import 'package:simplystyles/screens/auth/login_screen.dart';
import 'package:simplystyles/screens/home/home_screen.dart';
import 'package:simplystyles/screens/onboarding/onboarding_screen.dart';
import 'package:simplystyles/services/database_service.dart';
import './mock_firebase_setup.dart';

void main() {
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  // A helper function to wrap our app in the necessary providers
  // for a given test.
  Widget createTestApp({
    required MockFirebaseAuth auth,
    required FakeFirebaseFirestore firestore,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(auth: auth, firestore: firestore),
        ),
        Provider<DatabaseService>(
          create: (_) => DatabaseService(firestore: firestore),
        ),
      ],
      child: const SimplyStylesApp(),
    );
  }

  testWidgets('App smoke test (logged out)', (WidgetTester tester) async {
    // --- ARRANGE ---
    final fakeAuth = MockFirebaseAuth(signedIn: false);
    final fakeFirestore = FakeFirebaseFirestore();

    // --- ACT ---
    await tester.pumpWidget(createTestApp(
      auth: fakeAuth,
      firestore: fakeFirestore,
    ));
    await tester.pumpAndSettle();

    // --- ASSERT ---
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('App shows HomeScreen when user is logged in and onboarded',
      (WidgetTester tester) async {
    // --- ARRANGE ---
    final fakeUser =
        MockUser(uid: 'logged-in-onboarded-123', email: 'home@example.com');
    final fakeAuth = MockFirebaseAuth(signedIn: true, mockUser: fakeUser);
    final fakeFirestore = FakeFirebaseFirestore();
    // Add the user document marking onboarding as complete
    await fakeFirestore.collection('users').doc(fakeUser.uid).set({
      'email': fakeUser.email,
      'onboardingComplete': true,
    });

    // --- ACT ---
    await tester.pumpWidget(createTestApp(
      auth: fakeAuth,
      firestore: fakeFirestore,
    ));
    await tester.pumpAndSettle();

    // --- ASSERT ---
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets(
      'App shows OnboardingScreen for logged in user who is not onboarded',
      (WidgetTester tester) async {
    // --- ARRANGE ---
    final fakeUser =
        MockUser(uid: 'logged-in-not-onboarded-456', email: 'new@example.com');
    final fakeAuth = MockFirebaseAuth(signedIn: true, mockUser: fakeUser);
    final fakeFirestore = FakeFirebaseFirestore();
    // Add the user document marking onboarding as INCOMPLETE
    await fakeFirestore.collection('users').doc(fakeUser.uid).set({
      'email': fakeUser.email,
      'onboardingComplete': false,
    });

    // --- ACT ---
    await tester.pumpWidget(createTestApp(
      auth: fakeAuth,
      firestore: fakeFirestore,
    ));
    await tester.pumpAndSettle();

    // --- ASSERT ---
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('OnboardingScreen handles state and page navigation correctly',
      (WidgetTester tester) async {
    // --- ARRANGE ---
    final fakeUser =
        MockUser(uid: 'onboarding-test-789', email: 'onboarding@example.com');
    final fakeAuth = MockFirebaseAuth(signedIn: true, mockUser: fakeUser);
    final fakeFirestore = FakeFirebaseFirestore();
    await fakeFirestore.collection('users').doc(fakeUser.uid).set({
      'email': fakeUser.email,
      'onboardingComplete': false,
    });

    await tester.pumpWidget(createTestApp(
      auth: fakeAuth,
      firestore: fakeFirestore,
    ));
    await tester.pumpAndSettle();

    // --- ASSERT INITIAL STATE ---
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('What\'s your go-to style?'), findsOneWidget);
    expect(find.text('Selected: None'), findsOneWidget);

    // --- ACT & ASSERT: Update Style Preference ---
    await tester.tap(find.widgetWithText(ElevatedButton, 'Set to Chic'));
    await tester.pump(); // Rebuild the consumer

    expect(find.text('Selected: Chic'), findsOneWidget);

    // --- ACT & ASSERT: Navigate to Page 2 ---
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle(); // Animate to the next page

    expect(find.text('What\'s your go-to style?'), findsNothing);
    expect(find.text('What colors do you love?'), findsOneWidget);

    // --- ACT & ASSERT: Navigate to Page 3 ---
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('What colors do you love?'), findsNothing);
    expect(find.text('You\'re all set!'), findsOneWidget);

    // --- ACT & ASSERT: Navigate back to Page 2 ---
    await tester.tap(find.widgetWithText(TextButton, 'Back'));
    await tester.pumpAndSettle();

    expect(find.text('You\'re all set!'), findsNothing);
    expect(find.text('What colors do you love?'), findsOneWidget);
  });
}
