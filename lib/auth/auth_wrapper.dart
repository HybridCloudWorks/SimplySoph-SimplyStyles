import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplystyles/auth/auth_service.dart';
import 'package:simplystyles/screens/auth/login_screen.dart';
import 'package:simplystyles/screens/home/home_screen.dart';
import 'package:simplystyles/screens/onboarding/onboarding_screen.dart';
import 'package:simplystyles/services/database_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
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
            // This case can happen if the user is authenticated but the document
            // hasn't been created yet. You might want to show a loading screen
            // or even log them out.
            return const Scaffold(
              body: Center(
                child: Text('User data not found. Please try again.'),
              ),
            );
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
