import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import '../test/mock_helper.dart';

// Services
import 'package:simplystyles/services/wardrobe_service.dart';
import 'package:simplystyles/services/firestore_service.dart';
import 'package:simplystyles/services/image_service.dart';
import 'package:simplystyles/services/gamification_service.dart';
import 'package:simplystyles/services/persona_service.dart';
import 'package:simplystyles/services/email_service.dart';

// Mocks
class MockFirestoreService extends Mock implements FirestoreService {}
class MockImageService extends Mock implements ImageService {}
class MockGamificationService extends Mock implements GamificationService {}
class MockPersonaService extends Mock implements PersonaService {}
class MockEmailService extends Mock implements EmailService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  // 1. Setup the mocks FIRST
  setupFirebaseCoreMocks();

  setUpAll(() async {
    // 2. Now this won't throw a PlatformException
    await Firebase.initializeApp();
  });

  group('Closet Upload Integration Tests', () {
    late WardrobeService wardrobeService;
    
    setUp(() {
      wardrobeService = WardrobeService(
        firestoreService: MockFirestoreService(),
        imageService: MockImageService(),
        gamificationService: MockGamificationService(),
        personaService: MockPersonaService(),
        emailService: MockEmailService(),
      );
    });

    test('WardrobeService validates userId', () async {
      expect(
        () => wardrobeService.addItem(
          userId: '',
          imageBytes: Uint8List(10),
          category: 'tops',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('WardrobeService validates empty imageBytes', () async {
      expect(
        () => wardrobeService.addItem(
          userId: 'test-user',
          imageBytes: Uint8List(0),
          category: 'tops',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('WardrobeService validates category', () async {
      expect(
        () => wardrobeService.addItem(
          userId: 'test-user',
          imageBytes: Uint8List(10),
          category: '',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
