import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:simplystyles/auth/auth_service.dart';
import 'package:simplystyles/services/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'mock_firebase_setup.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() async {
    return MockGoogleSignInAccount();
  }

  @override
  Future<GoogleSignInAccount?> signOut() async {
    return null;
  }
}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {
  @override
  Future<GoogleSignInAuthentication> get authentication async {
    return MockGoogleSignInAuthentication();
  }
}

class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {
  @override
  String get idToken => 'mock_id_token';

  @override
  String get accessToken => 'mock_access_token';
}


void setupFirebaseAuthMocks() {
  setupFirebaseCoreMocks();
}

AuthService getMockAuthService() {
  final mockAuth = MockFirebaseAuth();
  final fakeFirestore = FakeFirebaseFirestore();
  final mockGoogleSignIn = MockGoogleSignIn();
  final firestoreService = FirestoreService(firestore: fakeFirestore);
  return AuthService(
    auth: mockAuth,
    firestoreService: firestoreService,
    googleSignIn: mockGoogleSignIn,
  );
}
