import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simplystyles/auth/auth_service.dart';
import 'mock.dart';

void main() {
  setupFirebaseAuthMocks();

  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      authService = getMockAuthService();
      mockAuth = authService.auth as MockFirebaseAuth;
      fakeFirestore = authService.firestoreService.firestore as FakeFirebaseFirestore;
    });

    test('signUp should create a user and a corresponding firestore document',
        () async {
      const email = 'test@example.com';
      const password = '123456';
      const displayName = 'Test User';

      await authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

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
      const email = 'test@example.com';
      const password = '123456';

      await mockAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await mockAuth.signOut();
      expect(mockAuth.currentUser, isNull);

      await authService.signIn(email: email, password: password);

      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser!.email, email);
    });

    test('signOut should log out the current user', () async {
      await mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: '123456',
      );
      expect(mockAuth.currentUser, isNotNull);

      await authService.signOut();

      expect(mockAuth.currentUser, isNull);
    });
  });
}
