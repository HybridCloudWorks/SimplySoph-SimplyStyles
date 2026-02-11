import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:simplystyles/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth auth;
  final FirestoreService firestoreService;
  final GoogleSignIn googleSignIn;

  AuthService({
    required this.auth,
    required this.firestoreService,
    required this.googleSignIn,
  });

  Stream<User?> get authStateChanges => auth.authStateChanges();

  User? get currentUser => auth.currentUser;

  Future<void> initializeAuth() async {
    // Wait for the first authentication state change to ensure Firebase is initialized.
    await auth.authStateChanges().first;
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Consider logging these errors for diagnostics
      throw Exception('Failed to sign in: ${e.message}');
    }
  }

  Future<User?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user != null) {
        await firestoreService.createUserDocument(user.uid, {
          'email': email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'onboardingComplete': false, // Initialize onboarding status
        });

        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign up: ${e.message}');
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await firestoreService.getUserProfile(user.uid);
        if (userDoc == null) {
          // New user
          await firestoreService.createUserDocument(user.uid, {
            'email': user.email,
            'displayName': user.displayName,
            'createdAt': FieldValue.serverTimestamp(),
            'onboardingComplete': false,
          });
        }
      }
      return user;
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  Future<User?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await firestoreService.getUserProfile(user.uid);
        if (userDoc == null) {
          // New user
          await firestoreService.createUserDocument(user.uid, {
            'email': user.email,
            'displayName': user.displayName,
            'createdAt': FieldValue.serverTimestamp(),
            'onboardingComplete': false,
          });
        }
      }
      return user;
    } catch (e) {
      throw Exception('Failed to sign in with Apple: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      await auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
