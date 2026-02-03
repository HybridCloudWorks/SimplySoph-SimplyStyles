import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplystyles/auth/auth_service.dart';
import 'package:simplystyles/screens/auth/login_screen.dart';
import 'package:simplystyles/screens/home/home_screen.dart';
import 'package:simplystyles/screens/onboarding/onboarding_screen.dart';
import 'package:simplystyles/services/database_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Wait for auth to be ready
    await authService.initializeAuth();

    if (mounted) {
      setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing...'),
            ],
          ),
        ),
      );
    }

    final authService = Provider.of<AuthService>(context);
    final databaseService = Provider.of<DatabaseService>(context);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const LoginScreen();
    } else {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: databaseService.getUserStream(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text('Error loading user data.'),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            // User authenticated but no document - create it and go to onboarding
            databaseService.createUserDocument(currentUser.uid, {
              'email': currentUser.email,
              'displayName': currentUser.displayName,
              'photoURL': currentUser.photoURL,
              'onboardingComplete': false,
              'preferences': {},
            });
            return const OnboardingScreen();
          }

          final userData = snapshot.data!.data();
          final onboardingComplete = userData?['onboardingComplete'] ?? false;

          if (onboardingComplete) {
            return const HomeScreen();
          } else {
            return const OnboardingScreen();
          }
        },
      );
    }
  }
}
