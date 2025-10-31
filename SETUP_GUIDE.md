# SimplyStyles Setup Guide

This guide will walk you through setting up the SimplyStyles app from scratch, including Firebase configuration and Gemini Cortex AI integration.

## Prerequisites

Before you begin, ensure you have the following installed on your development machine:

- **Flutter SDK** (version 3.0 or higher) - [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (comes with Flutter)
- **Android Studio** or **Xcode** (for mobile development)
- **Firebase CLI** - Install with `npm install -g firebase-tools`
- **Node.js** (version 18 or higher) - [Download](https://nodejs.org/)
- **Git** - [Download](https://git-scm.com/)

## Step 1: Firebase Project Setup

### 1.1 Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project**
3. Enter "SimplyStyles" as the project name
4. Follow the setup wizard (you can disable Google Analytics for now)
5. Click **Create project**

### 1.2 Enable Firebase Services

#### Authentication
1. In the Firebase Console, navigate to **Build** > **Authentication**
2. Click **Get started**
3. Go to the **Sign-in method** tab
4. Enable **Email/Password** authentication
5. Click **Save**

#### Firestore Database
1. Navigate to **Build** > **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (we'll add security rules later)
4. Choose a location close to your users
5. Click **Enable**

#### Firebase Storage
1. Navigate to **Build** > **Storage**
2. Click **Get started**
3. Start in **test mode**
4. Click **Done**

#### Cloud Functions
1. Navigate to **Build** > **Functions**
2. Click **Get started**
3. Follow the setup instructions

### 1.3 Register Your App

#### For Android
1. In the Firebase Console, click the Android icon
2. Enter your Android package name (e.g., `com.yourcompany.simplystyles`)
3. Download the `google-services.json` file
4. Place it in `android/app/` directory

#### For iOS
1. In the Firebase Console, click the iOS icon
2. Enter your iOS bundle ID (e.g., `com.yourcompany.simplystyles`)
3. Download the `GoogleService-Info.plist` file
4. Add it to your Xcode project in the `ios/Runner/` directory

## Step 2: Flutter Project Configuration

### 2.1 Update Package Name

Update the package name in the following files:

**android/app/build.gradle**
```gradle
defaultConfig {
    applicationId "com.yourcompany.simplystyles"
    // ... other config
}
```

**ios/Runner.xcodeproj/project.pbxproj**
Update the `PRODUCT_BUNDLE_IDENTIFIER` to match your bundle ID.

### 2.2 Install Dependencies

Run the following command in the project root:

```bash
flutter pub get
```

### 2.3 Configure Firebase in Flutter

The `main.dart` file already includes Firebase initialization. Ensure you have the Firebase configuration files in place as described in Step 1.3.

## Step 3: Gemini Cortex AI Integration

### 3.1 Obtain API Credentials

1. Sign up for Gemini Cortex AI access
2. Obtain your API endpoint URL and API key
3. Keep these credentials secure

### 3.2 Update API Configuration

**In Flutter App** (`lib/api/gemini_cortex_api.dart`):
```dart
static const String _baseUrl = 'https://your-actual-endpoint.com/api';
static const String _apiKey = 'YOUR_ACTUAL_API_KEY';
```

**In Cloud Functions**:
Set the API key using Firebase CLI:
```bash
firebase functions:config:set gemini.apikey="YOUR_ACTUAL_API_KEY"
```

Update the endpoint in `functions/src/index.js`:
```javascript
const GEMINI_CORTEX_API_URL = 'https://your-actual-endpoint.com/api';
```

## Step 4: Deploy Firebase Functions

### 4.1 Initialize Firebase

If you haven't already, initialize Firebase in your project:

```bash
firebase login
firebase init
```

Select:
- Functions
- Firestore
- Storage

### 4.2 Install Function Dependencies

```bash
cd functions
npm install
```

### 4.3 Deploy Functions

```bash
firebase deploy --only functions
```

## Step 5: Set Up Security Rules

### 5.1 Firestore Security Rules

In the Firebase Console, go to **Firestore Database** > **Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /wardrobe_items/{itemId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /style_personas/{personaId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /trends/{trendId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    
    match /recommendations/{recommendationId} {
      allow read: if request.auth != null && 
        resource.data.userId == request.auth.uid;
      allow write: if false;
    }
  }
}
```

Click **Publish**.

### 5.2 Storage Security Rules

Go to **Storage** > **Rules** and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Click **Publish**.

## Step 6: Run the App

### 6.1 Connect a Device or Emulator

- For Android: Start an Android emulator or connect a physical device
- For iOS: Start an iOS simulator or connect a physical device

### 6.2 Run the App

```bash
flutter run
```

The app should now build and launch on your device!

## Step 7: Testing

### 7.1 Create a Test Account

1. Launch the app
2. Click **Sign Up**
3. Enter test credentials
4. Create your account

### 7.2 Test Core Features

1. **Smart Closet**: Try adding an item using the camera or gallery
2. **Scanner**: Test the persona-fit scanner (note: requires actual Gemini Cortex AI integration)
3. **Trends**: Browse the trend wall
4. **Recommendations**: View personalized recommendations

## Troubleshooting

### Common Issues

**Firebase initialization error**
- Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in the correct locations
- Verify package name/bundle ID matches Firebase configuration

**Cloud Functions not working**
- Check that functions are deployed: `firebase deploy --only functions`
- Verify API key is set: `firebase functions:config:get`
- Check function logs: `firebase functions:log`

**Gemini Cortex AI errors**
- Verify API endpoint and key are correct
- Check network connectivity
- Review API documentation for proper request format

### Getting Help

- Check the [Flutter documentation](https://docs.flutter.dev/)
- Review [Firebase documentation](https://firebase.google.com/docs)
- Open an issue on the project GitHub repository

## Next Steps

Once the app is running, consider:

1. Implementing additional features from the roadmap
2. Customizing the UI to match your brand
3. Adding analytics to track user behavior
4. Preparing for production deployment
5. Setting up CI/CD pipelines

## Production Deployment

Before deploying to production:

1. Update Firebase security rules to be more restrictive
2. Enable Firebase App Check for additional security
3. Set up proper error tracking (e.g., Firebase Crashlytics)
4. Configure environment variables for different environments
5. Test thoroughly on multiple devices
6. Submit to App Store and Google Play Store

---

**Congratulations!** You've successfully set up the SimplyStyles app. Happy coding! 🎉
