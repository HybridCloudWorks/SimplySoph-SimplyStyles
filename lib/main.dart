import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_service.dart';
import 'auth/auth_wrapper.dart';
import 'firebase_options.dart';
import 'services/database_service.dart';
import 'services/firestore_service.dart';
import 'services/image_service.dart';
import 'services/wardrobe_service.dart';
import 'state/onboarding_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(
            auth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          ),
        ),
        Provider<DatabaseService>(
          create: (_) => DatabaseService(
            firestore: FirebaseFirestore.instance,
          ),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        Provider<ImageService>(
          create: (_) => ImageService(),
        ),
        ProxyProvider2<FirestoreService, ImageService, WardrobeService>(
          update: (_, firestoreService, imageService, __) => WardrobeService(
            firestoreService: firestoreService,
            imageService: imageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingState(),
        ),
      ],
      child: const SimplyStylesApp(),
    ),
  );
}

class SimplyStylesApp extends StatelessWidget {
  const SimplyStylesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimplyStyles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'HappyMonkey',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF8FF),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
