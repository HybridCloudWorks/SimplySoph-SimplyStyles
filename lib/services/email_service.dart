import 'package:cloud_firestore/cloud_firestore.dart';

class EmailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendWelcomeEmail(String email, String displayName) async {
    await _firestore.collection('mail').add({
      'to': email,
      'message': {
        'subject': 'Welcome to SimplyStyles! 👗',
        'html': '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; text-align: center;">
              <h1 style="color: white; margin: 0;">Welcome to SimplyStyles!</h1>
            </div>
            <div style="padding: 40px; background: #f9f9f9;">
              <h2>Hi $displayName! 👋</h2>
              <p>We're thrilled to have you join our fashion community.</p>
              <p>Get started by adding your first clothing item to your digital wardrobe!</p>
              <div style="text-align: center; margin: 30px 0;">
                <a href="https://simplysoph-66c78.web.app" 
                   style="background: #667eea; color: white; padding: 15px 30px; 
                          text-decoration: none; border-radius: 5px; display: inline-block;">
                  Open App
                </a>
              </div>
            </div>
          </div>
        ''',
      },
    });
  }

  Future<void> sendOnboardingCompleteEmail(String email, String displayName) async {
    await _firestore.collection('mail').add({
      'to': email,
      'message': {
        'subject': 'Your Style Profile is Ready! ✨',
        'html': '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="padding: 40px; background: #f9f9f9;">
              <h1>🎉 Profile Complete!</h1>
              <p>Hi $displayName,</p>
              <p>Your style preferences have been saved and your AI stylist is ready to help!</p>
              <h3>Next Steps:</h3>
              <ol>
                <li>Add your first clothing item</li>
                <li>Let AI analyze your style</li>
                <li>Get personalized outfit recommendations</li>
              </ol>
              <div style="text-align: center; margin: 30px 0;">
                <a href="https://simplysoph-66c78.web.app/closet" 
                   style="background: #667eea; color: white; padding: 15px 30px; 
                          text-decoration: none; border-radius: 5px; display: inline-block;">
                  Add Your First Item
                </a>
              </div>
            </div>
          </div>
        ''',
      },
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firestore.collection('mail').add({
      'to': email,
      'message': {
        'subject': 'Reset Your SimplyStyles Password',
        'html': '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="padding: 40px;">
              <h2>Password Reset Request</h2>
              <p>We received a request to reset your password.</p>
              <p>If you didn't make this request, you can safely ignore this email.</p>
            </div>
          </div>
        ''',
      },
    });
  }
}
