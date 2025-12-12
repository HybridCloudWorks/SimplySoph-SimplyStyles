import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/email_service.dart';

class AuthService extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final EmailService _emailService;

  User? get currentUser => _auth.currentUser;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get the current user's ID token (refreshes if needed)
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await _auth.currentUser?.getIdToken(forceRefresh);
    } catch (e) {
      debugPrint('Error getting ID token: $e');
      return null;
    }
  }

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    EmailService? emailService,
  }) {
    _auth = auth ?? FirebaseAuth.instance;
    _firestore = firestore ?? FirebaseFirestore.instance;
    _emailService = emailService ?? EmailService(firestore: _firestore);

    // Set up authentication persistence immediately
    _configureAuthPersistence();

    // Listen to authentication state changes
    _auth.authStateChanges().listen((User? user) {
      debugPrint('Auth state changed: ${user?.email ?? 'null'}');
      notifyListeners();
    });

    // Also listen to ID token changes for more reliable state tracking
    _auth.idTokenChanges().listen((User? user) {
      debugPrint('ID token changed: ${user?.email ?? 'null'}');
    });

    if (kIsWeb) {
      _handleWebRedirectResult();
    }
  }

  /// Configure authentication persistence based on platform
  Future<void> _configureAuthPersistence() async {
    try {
      if (kIsWeb) {
        // For web, use local persistence to remember users across sessions
        await _auth.setPersistence(Persistence.LOCAL);
        debugPrint('Firebase Auth persistence set to LOCAL for web');
      } else {
        // For mobile platforms, Firebase Auth automatically uses local persistence
        // but we can ensure it's configured properly
        debugPrint(
            'Firebase Auth using automatic local persistence for mobile');
      }
    } catch (e) {
      debugPrint('Error configuring auth persistence: $e');
      // Continue anyway - Firebase Auth has default persistence
    }
  }

  /// Initialize authentication state - call this to ensure auth is ready
  Future<void> initializeAuth() async {
    try {
      // Wait for Firebase Auth to be ready
      await _auth.authStateChanges().first;
      debugPrint('Firebase Auth initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase Auth: $e');
    }
  }

  Future<void> _handleWebRedirectResult() async {
    try {
      final UserCredential result = await _auth.getRedirectResult();
      if (result.user != null) {
        final userCredential = result;
        if (userCredential.additionalUserInfo?.isNewUser == true) {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'email': userCredential.user!.email,
            'displayName': userCredential.user!.displayName,
            'photoURL': userCredential.user!.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'onboardingComplete': false,
            'preferences': {},
            'provider': 'google',
          });
        }
        notifyListeners();
      }
    } catch (_) {
      // Ignore - no redirect result or not applicable
    }
  }

  /// Trigger redirect sign-in for Google on web. UI can call this if popup fails.
  Future<void> signInWithRedirectForGoogle() async {
    if (!kIsWeb) return;
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    await _auth.signInWithRedirect(googleProvider);
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'onboardingComplete': false,
        'preferences': {},
      });

      // Send welcome email
      await _emailService.sendWelcomeEmail(userCredential.user!.uid, email);

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during sign up';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Ensure persistence is configured before signing in
      await _configureAuthPersistence();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('User signed in successfully: $email');
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign in error: ${e.code} - ${e.message}');
      return e.message ?? 'An error occurred during sign in';
    } catch (e) {
      debugPrint('Unexpected sign in error: $e');
      return 'An unexpected error occurred';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('User signed out successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      // Still notify listeners even if there's an error
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<String?> signInWithGoogle() async {
    try {
      // Ensure persistence is configured before signing in
      await _configureAuthPersistence();

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        try {
          final UserCredential userCredential =
              await _auth.signInWithPopup(googleProvider);

          // Create user document if new user
          if (userCredential.additionalUserInfo?.isNewUser == true) {
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'email': userCredential.user!.email,
              'displayName': userCredential.user!.displayName,
              'photoURL': userCredential.user!.photoURL,
              'createdAt': FieldValue.serverTimestamp(),
              'onboardingComplete': false,
              'preferences': {},
              'provider': 'google',
            });

            // Send welcome email
            await _emailService.sendWelcomeEmail(
                userCredential.user!.uid, userCredential.user!.email!);
          }

          debugPrint(
              'Google sign in successful: ${userCredential.user!.email}');
          notifyListeners();
          return null;
        } on FirebaseAuthException catch (e) {
          // Popup may be blocked in embedded browsers or the Simple Browser.
          // Return a special code so the UI can show a helpful message and
          // optionally fall back to redirect flow automatically.
          if (e.code == 'popup-blocked' ||
              e.code == 'popup_closed_by_user' ||
              e.code == 'web-storage-unsupported') {
            return 'ERROR_POPUP_BLOCKED';
          }
          debugPrint('Google sign in error: ${e.code} - ${e.message}');
          return 'Google sign in failed: ${e.message ?? e.code}';
        }
      } else {
        // Mobile Google Sign-In not implemented yet
        return 'Google Sign-In only available on web';
      }
    } catch (e) {
      debugPrint('Unexpected Google sign in error: $e');
      return 'Google sign in failed: ${e.toString()}';
    }
  }

  Future<String?> signInWithApple() async {
    try {
      // Ensure persistence is configured before signing in
      await _configureAuthPersistence();

      final appleProvider = AppleAuthProvider();
      final UserCredential userCredential =
          await _auth.signInWithProvider(appleProvider);

      // Create user document if new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'photoURL': userCredential.user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'onboardingComplete': false,
          'preferences': {},
          'provider': 'apple',
        });

        // Send welcome email
        await _emailService.sendWelcomeEmail(
            userCredential.user!.uid, userCredential.user!.email!);
      }

      debugPrint('Apple sign in successful: ${userCredential.user!.email}');
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Apple sign in error: $e');
      return 'Apple sign in failed: ${e.toString()}';
    }
  }
}
