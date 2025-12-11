import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simplystyles/auth/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService', () {
    // Mocks
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    // Service under test
    late AuthService authService;

    // This function is run before each test
    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
      authService = AuthService(auth: mockAuth, firestore: fakeFirestore);
    });

    test('signUp should create a user and a corresponding firestore document',
        () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const displayName = 'Test User';

      // Act
      await authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Assert
      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser!.email, email);
      expect(mockAuth.currentUser!.displayName, displayName);

      final userDoc = await fakeFirestore
          .collection('users')
          .doc(mockAuth.currentUser!.uid)
          .get();
      expect(userDoc.exists, isTrue);
      expect(userDoc.data()?['email'], email);
    });

    test('signIn should log in an existing user', () async {
      // --- ARRANGE ---
      const email = 'test@example.com';
      const password = 'password123';

      // Manually create the user in the FAKE auth system first
      await mockAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Now, sign them out so we can test the sign-in flow
      await mockAuth.signOut();
      expect(mockAuth.currentUser, isNull);

      // --- ACT ---
      // Call the real sign-in method from the service
      await authService.signIn(email: email, password: password);

      // --- ASSERT ---
      // Check that we are now logged in as that user
      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser!.email, email);
    });

    test('signOut should log out the current user', () async {
      // --- ARRANGE ---
      // Start in a "logged-in" state.
      await mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(mockAuth.currentUser, isNotNull);

      // --- ACT ---
      await authService.signOut();

      // --- ASSERT ---
      expect(mockAuth.currentUser, isNull);
    });
  });
}
