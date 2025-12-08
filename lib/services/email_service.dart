import 'package:cloud_firestore/cloud_firestore.dart';

class EmailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendWelcomeEmail(String userId, String email) async {
    await _firestore.collection('mail').add({
      'to': email,
      'message': {
        'subject': 'Welcome to SimplyStyles! 👗',
        'html': '''
          <h1>Welcome to SimplyStyles!</h1>
          <p>We're excited to help you discover your perfect style.</p>
          <p>Start by adding your first clothing item to build your digital wardrobe.</p>
          <a href="https://simplysoph-66c78.web.app">Get Started</a>
        ''',
      },
      'userId': userId,
      'type': 'welcome',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendOnboardingCompleteEmail(String userId, String email) async {
    await _firestore.collection('mail').add({
      'to': email,
      'message': {
        'subject': 'Your style journey begins! ✨',
        'html': '''
          <h1>Onboarding Complete!</h1>
          <p>You're all set up and ready to explore your style.</p>
          <p>Add 5 items to unlock AI-powered style personas and recommendations.</p>
          <a href="https://simplysoph-66c78.web.app/closet">Add Items</a>
        ''',
      },
      'userId': userId,
      'type': 'onboarding_complete',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendFirstItemEmail(String userId, String email) async {
    await _firestore.collection('mail').add({
      'to': email,
      'message': {
        'subject': 'Great start! Keep building your wardrobe 👕',
        'html': '''
          <h1>First Item Added!</h1>
          <p>Awesome! You've added your first item to your digital wardrobe.</p>
          <p>Add 4 more items to unlock personalized style recommendations.</p>
          <a href="https://simplysoph-66c78.web.app/closet">Continue Building</a>
        ''',
      },
      'userId': userId,
      'type': 'first_item',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}