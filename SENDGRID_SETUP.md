# SendGrid Email Extension Setup

## SendGrid Configuration

### 1. Get SendGrid API Key
1. Go to https://app.sendgrid.com/settings/api_keys
2. Click **Create API Key**
3. Name: `Firebase-SimplyStyles`
4. Permissions: **Full Access** (or at minimum: Mail Send)
5. Copy the API key (save it - you can't see it again)

### 2. Verify Sender Identity
1. Go to https://app.sendgrid.com/settings/sender_auth/senders
2. Click **Create New Sender**
3. Fill in:
   - **From Name**: SimplyStyles
   - **From Email**: noreply@simplysoph.com (or your verified email)
   - **Reply To**: support@simplysoph.com (or same as From)
   - **Company Address**: Your address
4. Click **Create**
5. Check your email and verify

**Note**: Free tier requires single sender verification. For custom domain (noreply@simplystyles.app), you need domain authentication (paid).

## Install Firebase Extension

### Via Firebase Console (Easiest)
1. Go to https://console.firebase.google.com/project/simplysoph-66c78/extensions
2. Click **Install extension**
3. Search: **Trigger Email from Firestore**
4. Click **Install**
5. Configure:

```
SMTP Connection URI:
smtps://apikey:YOUR_SENDGRID_API_KEY@smtp.sendgrid.net:465

Email documents collection:
mail

Default FROM address:
noreply@simplysoph.com

Default REPLY-TO address:
support@simplysoph.com
```

6. Click **Install extension**

### Via CLI
```bash
firebase ext:install firebase/firestore-send-email
```

When prompted:
- **SMTP connection URI**: `smtps://apikey:YOUR_SENDGRID_API_KEY@smtp.sendgrid.net:465`
- **Email collection**: `mail`
- **Default FROM**: `noreply@simplysoph.com`
- **Default REPLY-TO**: `support@simplysoph.com`

## SMTP URI Format

```
smtps://apikey:YOUR_ACTUAL_API_KEY@smtp.sendgrid.net:465
```

**Example**:
```
smtps://apikey:SG.abc123xyz789.def456uvw012@smtp.sendgrid.net:465
```

**Important**: 
- Username is literally `apikey`
- Password is your actual SendGrid API key
- Use `smtps://` (with 's' for SSL)
- Port is `465`

## Test Email

After installation, test with Firestore:

```dart
await FirebaseFirestore.instance.collection('mail').add({
  'to': 'your-email@example.com',
  'message': {
    'subject': 'Test Email from SimplyStyles',
    'text': 'This is a test email.',
    'html': '<h1>Test Email</h1><p>This is a test email from SimplyStyles.</p>',
  },
});
```

Check the document - it should update with:
- `delivery.state: 'SUCCESS'`
- `delivery.info.messageId: '<message-id>'`

## Email Templates

### Welcome Email
```dart
await FirebaseFirestore.instance.collection('mail').add({
  'to': userEmail,
  'message': {
    'subject': 'Welcome to SimplyStyles! 👗',
    'html': '''
      <!DOCTYPE html>
      <html>
      <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; text-align: center;">
          <h1 style="color: white; margin: 0;">Welcome to SimplyStyles!</h1>
        </div>
        <div style="padding: 40px; background: #f9f9f9;">
          <h2>Hi ${userName}! 👋</h2>
          <p>We're thrilled to have you join our fashion community.</p>
          <p>SimplyStyles is your AI-powered wardrobe assistant, here to help you:</p>
          <ul>
            <li>Organize your closet digitally</li>
            <li>Get personalized outfit recommendations</li>
            <li>Discover your unique style</li>
          </ul>
          <div style="text-align: center; margin: 30px 0;">
            <a href="https://simplysoph-66c78.web.app" 
               style="background: #667eea; color: white; padding: 15px 30px; 
                      text-decoration: none; border-radius: 5px; display: inline-block;">
              Get Started
            </a>
          </div>
          <p style="color: #666; font-size: 12px; margin-top: 40px;">
            Questions? Reply to this email or visit our help center.
          </p>
        </div>
      </body>
      </html>
    ''',
  },
});
```

### Onboarding Complete Email
```dart
await FirebaseFirestore.instance.collection('mail').add({
  'to': userEmail,
  'message': {
    'subject': 'Your Style Profile is Ready! ✨',
    'html': '''
      <!DOCTYPE html>
      <html>
      <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="padding: 40px; background: #f9f9f9;">
          <h1>🎉 Profile Complete!</h1>
          <p>Hi ${userName},</p>
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
      </body>
      </html>
    ''',
  },
});
```

## Code Integration

### Add to AuthService (Welcome Email)
```dart
// In lib/services/auth_service.dart after user creation
Future<User?> signUpWithEmail(String email, String password, String displayName) async {
  try {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    await credential.user?.updateDisplayName(displayName);
    
    // Send welcome email
    await FirebaseFirestore.instance.collection('mail').add({
      'to': email,
      'message': {
        'subject': 'Welcome to SimplyStyles! 👗',
        'html': '<h1>Welcome $displayName!</h1><p>Get started by adding your first item.</p>',
      },
    });
    
    return credential.user;
  } catch (e) {
    rethrow;
  }
}
```

### Add to FirestoreService (Onboarding Complete)
```dart
// In lib/services/firestore_service.dart
Future<void> saveAndCompleteOnboarding({
  required String userId,
  required String userEmail,
  required Map<String, dynamic> onboardingData,
}) async {
  await _firestore.collection('users').doc(userId).set({
    ...onboardingData,
    'onboardingComplete': true,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  // Send completion email
  await _firestore.collection('mail').add({
    'to': userEmail,
    'message': {
      'subject': 'Your Style Profile is Ready! ✨',
      'html': '<h1>Profile Complete!</h1><p>Start building your wardrobe now.</p>',
    },
  });
}
```

## Monitoring

### Check Email Status
```dart
// Query mail collection to see delivery status
final mailDocs = await FirebaseFirestore.instance
  .collection('mail')
  .orderBy('delivery.startTime', descending: true)
  .limit(10)
  .get();

for (var doc in mailDocs.docs) {
  print('To: ${doc.data()['to']}');
  print('State: ${doc.data()['delivery']?['state']}');
  print('Error: ${doc.data()['delivery']?['error']}');
}
```

### View Logs
1. Firebase Console → Extensions → Trigger Email
2. Click **View in Cloud Functions**
3. Check logs for errors

### SendGrid Dashboard
1. Go to https://app.sendgrid.com/email_activity
2. View sent emails, opens, clicks, bounces

## Troubleshooting

### Emails Not Sending
1. Check SMTP URI format is correct
2. Verify SendGrid API key has Mail Send permission
3. Verify sender email is verified in SendGrid
4. Check extension logs in Firebase Console
5. Check `mail` collection documents for `delivery.error`

### Emails Going to Spam
1. Verify sender in SendGrid
2. Add SPF/DKIM records (domain authentication)
3. Avoid spam trigger words
4. Include unsubscribe link

### Rate Limits (Free Tier)
- **100 emails/day** on SendGrid free tier
- Extension will queue emails if rate limited
- Upgrade SendGrid plan if needed

## SendGrid Free Tier Limits
- 100 emails/day
- Single sender verification
- Basic email analytics
- No custom domain (use verified email)

## Next Steps
1. ✅ Create SendGrid account
2. ⬜ Get API key
3. ⬜ Verify sender email
4. ⬜ Install extension with SMTP URI
5. ⬜ Test with sample email
6. ⬜ Add welcome email to signup
7. ⬜ Add completion email to onboarding
8. ⬜ Monitor delivery in SendGrid dashboard
