import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/email_service.dart';

class AuthService extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  final EmailService _emailService = EmailService();

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore}) {
    _auth = auth ?? FirebaseAuth.instance;
    _firestore = firestore ?? FirebaseFirestore.instance;
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
    if (kIsWeb) {
      _handleWebRedirectResult();
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
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during sign in';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<String?> signInWithGoogle() async {
    try {
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
            await _emailService.sendWelcomeEmail(userCredential.user!.uid, userCredential.user!.email!);
          }

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
          return 'Google sign in failed: ${e.message ?? e.code}';
        }
      } else {
        // Mobile Google Sign-In not implemented yet
        return 'Google Sign-In only available on web';
      }
    } catch (e) {
      return 'Google sign in failed: ${e.toString()}';
    }
  }

  Future<String?> signInWithApple() async {
    try {
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
        await _emailService.sendWelcomeEmail(userCredential.user!.uid, userCredential.user!.email!);
      }

      notifyListeners();
      return null;
    } catch (e) {
      return 'Apple sign in failed: ${e.toString()}';
    }
  }
}
