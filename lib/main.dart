import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:simplystyles/services/email_service.dart';
import 'package:simplystyles/services/persona_service.dart';
import 'package:simplystyles/services/social_service.dart';

import 'auth/auth_wrapper.dart';
import 'auth/auth_service.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'services/gamification_service.dart';
import 'services/image_service.dart';
import 'services/wardrobe_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate services
    final firebaseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final googleSignIn = GoogleSignIn();

    final firestoreService = FirestoreService(firestore: firestore);
    final authService = AuthService(
      auth: firebaseAuth,
      firestoreService: firestoreService,
      googleSignIn: googleSignIn,
    );
    final imageService = ImageService();
    final gamificationService = GamificationService(firestore);
    final socialService = SocialService();
    final personaService = PersonaService(firestore);
    final emailService = EmailService();

    final wardrobeService = WardrobeService(
        firestoreService: firestoreService,
        imageService: imageService,
        gamificationService: gamificationService,
        personaService: personaService, 
        emailService: emailService, 
    );

    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<ImageService>.value(value: imageService),
        Provider<GamificationService>.value(value: gamificationService),
        Provider<WardrobeService>.value(value: wardrobeService),
        Provider<SocialService>.value(value: socialService),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimplyStyles',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}
