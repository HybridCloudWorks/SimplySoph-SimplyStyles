# Setup

Consolidated setup instructions for local dev, Firebase, and IDE.

### Consolidated Sources

- SETUP_GUIDE.md
- QUICK_START.md
- VSCODE_SETUP.md

---

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
const GEMINI_CORTEX_API_URL = "https://your-actual-endpoint.com/api";
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

---

# SimplyStyles: Visual Studio Code Setup Guide

Welcome to the SimplyStyles project! This guide will walk you through setting up your development environment in Visual Studio Code (VS Code) for a smooth and productive experience. I've already included a pre-configured `.vscode` folder in the project to get you started quickly.

## 1. Prerequisites

Before you begin, make sure you have the following installed:

- **Visual Studio Code**: The best code editor for Flutter. [Download it here](https://code.visualstudio.com/).
- **Flutter SDK**: The framework for building the app. [Installation Guide](https://docs.flutter.dev/get-started/install).
- **Git**: For version control (highly recommended). [Download it here](https://git-scm.com/).

## 2. Initial Setup

### Step 1: Open the Project in VS Code

1.  Unzip the `simplystyles_mvp.zip` file on your computer.
2.  Open VS Code.
3.  Go to **File > Open Folder...** and select the `simplystyles` folder.

### Step 2: Install Recommended Extensions

When you open the project, VS Code might show a notification in the bottom-right corner saying, "This workspace has recommended extensions." This is because I've included an `extensions.json` file.

1.  Click **Install** on that notification. This will automatically install all the recommended extensions for Flutter and Firebase development.

    _If you don't see the notification, go to the **Extensions** view (Ctrl+Shift+X), type `@recommended` in the search bar, and install them from there._

    ![VS Code Recommended Extensions](https://i.imgur.com/8g3j4kL.png)

### Step 3: Get Flutter Packages

Open the integrated terminal in VS Code (**View > Terminal** or `Ctrl+\``) and run this command to download all the necessary project dependencies:

```bash
flutter pub get
```

## 3. Understanding the `.vscode` Folder

I've created a `.vscode` folder for you with pre-configured settings to make your life easier. Here's what each file does:

- **`launch.json`**: This file configures how you run and debug the app. I've set up three launch configurations:

  - **SimplyStyles (Debug)**: The default mode for development. It enables features like Hot Reload.
  - **SimplyStyles (Profile)**: For analyzing your app's performance.
  - **SimplyStyles (Release)**: For building the final, optimized version of your app.

- **`settings.json`**: This file customizes your VS Code settings specifically for this project. It enables features like automatic formatting on save, sets the line length to 80 characters, and hides unnecessary folders from the file explorer.

- **`extensions.json`**: This file lists all the recommended VS Code extensions for this project, which you installed in Step 2.

- **`tasks.json`**: This file defines common commands you can run directly from VS Code. I've set up tasks for things like cleaning the project, getting packages, and deploying Firebase functions.

## 4. Running and Debugging the App

This is the fun part!

1.  **Select a Device**: In the bottom-right corner of the VS Code status bar, click on the device name (e.g., "Chrome (web)") to select a target device. You can choose a connected phone, an emulator/simulator, or a web browser.

    ![VS Code Device Selection](https://i.imgur.com/BqgY2XF.png)

2.  **Start Debugging**: Go to the **Run and Debug** view (Ctrl+Shift+D) on the left sidebar.

3.  **Select Configuration**: At the top, you'll see a dropdown menu. Make sure **"SimplyStyles (Debug)"** is selected.

4.  **Press Play**: Click the green play button (or press **F5**) to start the app. VS Code will build the app and launch it on your selected device.

    ![VS Code Run and Debug](https://i.imgur.com/tF5gJ7d.png)

### Hot Reload

One of Flutter's best features is **Hot Reload**. While the app is running in Debug mode:

- Make a change to your code (e.g., change a text label).
- Save the file (Ctrl+S).
- The app will update instantly on your device without restarting! ⚡️

## 5. Using the Custom Tasks

I've set up some useful tasks to speed up your workflow.

1.  Open the Command Palette (**Ctrl+Shift+P**).
2.  Type **"Tasks: Run Task"** and press Enter.
3.  You'll see a list of the tasks I created in `tasks.json`:
    - `Flutter: Clean`: Cleans the build directory.
    - `Flutter: Get Packages`: Runs `flutter pub get`.
    - `Firebase: Deploy Functions`: Deploys your backend code.

## 6. Securely Managing API Keys

Your project needs an API key for Gemini Cortex AI. It's very important **not to save your secret API key directly in the code**, especially if you plan to share your project on GitHub.

### Recommended Method: Environment Variables

1.  **Create a `.env` file**: In the root of your `simplystyles` folder, create a new file named `.env`.

2.  **Add your key to `.env`**:

    ```
    GEMINI_CORTEX_API_KEY=your_super_secret_api_key_here
    ```

3.  **IMPORTANT: Add `.env` to `.gitignore`**: I have already added `.env` to the `.gitignore` file. This tells Git to **never** upload this file to GitHub, keeping your key safe.

4.  **Accessing the key in your code**: You'll need a package like `flutter_dotenv` to load these variables. I have not included it by default to keep the project simple, but it's a great next step!

For now, you can temporarily paste your key into the `lib/api/gemini_cortex_api.dart` file for testing, but remember to remove it before you commit your code to GitHub!

## 7. Next Steps

1.  **Follow the `SETUP_GUIDE.md`**: This guide has detailed instructions for setting up your Firebase project.
2.  **Explore the Code**: Start with `lib/main.dart` and navigate through the different screens and widgets.
3.  **Start Building**: Try changing some UI elements, adding a new feature, or connecting your actual Firebase backend.

Happy coding! If you have any more questions, just ask. You've got this! 🚀

---

# SimplyStyles Quick Start Checklist ✅

Follow this checklist to get your SimplyStyles app up and running!

## Before You Start

- [ ] Download and install [Visual Studio Code](https://code.visualstudio.com/)
- [ ] Download and install [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [ ] Download and install [Git](https://git-scm.com/) (optional but recommended)
- [ ] Create a [Firebase account](https://firebase.google.com/)

## Step 1: Open Project in VS Code (5 minutes)

- [ ] Unzip `simplystyles_mvp.zip` to a folder on your computer
- [ ] Open VS Code
- [ ] Go to **File > Open Folder** and select the `simplystyles` folder
- [ ] When prompted, click **Install** to install recommended extensions
- [ ] Wait for extensions to install (this might take a minute)

## Step 2: Install Dependencies (2 minutes)

- [ ] Open the terminal in VS Code (**View > Terminal** or press `Ctrl+`\`)
- [ ] Run this command:
  ```bash
  flutter pub get
  ```
- [ ] Wait for packages to download

## Step 3: Set Up Firebase (15 minutes)

- [ ] Go to [Firebase Console](https://console.firebase.google.com/)
- [ ] Click **Add Project** and name it "SimplyStyles"
- [ ] Enable **Authentication** with Email/Password
- [ ] Create a **Firestore Database** (start in test mode)
- [ ] Set up **Firebase Storage**
- [ ] Register your app:
  - For Android: Download `google-services.json` → place in `android/app/`
  - For iOS: Download `GoogleService-Info.plist` → place in `ios/Runner/`

**Detailed instructions**: See `SETUP_GUIDE.md` for step-by-step Firebase setup

## Step 4: Configure Gemini Cortex AI (5 minutes)

- [ ] Get your Gemini Cortex AI API key
- [ ] Open `lib/api/gemini_cortex_api.dart`
- [ ] Replace `'YOUR_API_KEY_HERE'` with your actual API key
- [ ] Replace `'https://your-gemini-cortex-endpoint.com/api'` with your actual endpoint

**Security Note**: Before uploading to GitHub, move your API key to a `.env` file!

## Step 5: Run the App (2 minutes)

- [ ] Connect a device or start an emulator
- [ ] In VS Code, click the device name in the bottom-right corner
- [ ] Select your device from the list
- [ ] Press **F5** or click the green play button
- [ ] Wait for the app to build and launch

## Step 6: Test the App (5 minutes)

- [ ] Create a test account using the Sign Up screen
- [ ] Log in with your credentials
- [ ] Explore the 5 main screens:
  - [ ] Home (Dashboard)
  - [ ] Smart Closet
  - [ ] Persona-Fit Scanner
  - [ ] Trend Wall
  - [ ] Shop (Recommendations)

## Optional: Deploy Firebase Functions (10 minutes)

- [ ] Install [Node.js](https://nodejs.org/) (version 18+)
- [ ] Install Firebase CLI: `npm install -g firebase-tools`
- [ ] Login to Firebase: `firebase login`
- [ ] Navigate to functions folder: `cd functions`
- [ ] Install dependencies: `npm install`
- [ ] Configure API key: `firebase functions:config:set gemini.apikey="YOUR_KEY"`
- [ ] Deploy: `firebase deploy --only functions`

## Optional: Upload to GitHub (10 minutes)

- [ ] Create a new repository on [GitHub](https://github.com/)
- [ ] In VS Code, click the **Source Control** icon (left sidebar)
- [ ] Click **Initialize Repository**
- [ ] Stage all changes (click the + icon next to "Changes")
- [ ] Enter commit message: "Initial commit: SimplyStyles MVP"
- [ ] Click **Publish to GitHub**
- [ ] Choose **Private** or **Public**
- [ ] Done!

## Troubleshooting

### "Flutter SDK not found"

- Make sure you've installed Flutter and added it to your PATH
- Restart VS Code after installing Flutter

### "No devices found"

- For Android: Start an Android emulator from Android Studio
- For iOS: Open Xcode and start an iOS Simulator
- For Web: Chrome should appear automatically

### Firebase errors

- Double-check that `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) are in the correct folders
- Make sure your package name matches what you entered in Firebase Console

### Need Help?

- Check `VSCODE_SETUP.md` for detailed VS Code instructions
- Check `SETUP_GUIDE.md` for detailed Firebase setup
- Check `README.md` for project overview

---

**Estimated Total Time**: 45-60 minutes

**You're all set! Happy coding! 🎉**

---

# SimplyStyles: Firebase Hosting Guide 🚀

Congratulations on building your app! Now, let's get it live on the web so you can share it with the world. This guide will walk you through deploying your SimplyStyles Flutter app using **Firebase Hosting**.

## What is Firebase Hosting?

Firebase Hosting is a service that lets you publish web apps and static content with a single command. It's fast, secure, and provides a free SSL certificate, so your site will be `https`.

## Prerequisites

Before you start, make sure you have:

1.  **A Firebase Project**: You should already have this from the initial setup.
2.  **Firebase CLI**: The command-line tool for Firebase. If you haven't installed it, open your terminal and run:
    ```bash
    npm install -g firebase-tools
    ```
3.  **Logged into Firebase**: In your terminal, run:
    ```bash
    firebase login
    ```

## Step 1: Enable Firebase Hosting

1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Select your **SimplyStyles** project.
3.  In the left-hand menu, go to **Build > Hosting**.
4.  Click **Get started**.
5.  Follow the on-screen instructions. You don't need to do anything with the code snippets it shows you just yet—we'll handle that in the next steps.

## Step 2: Initialize Firebase Hosting in Your Project

Now, we'll tell your local project that you want to use Firebase Hosting.

1.  **Open your terminal** and navigate to your `simplystyles` project folder:

    ```bash
    cd path/to/your/simplystyles
    ```

2.  **Run the init command**:

    ```bash
    firebase init hosting
    ```

3.  **Answer the questions**:
    - **"Please select an option:"** → Select **Use an existing project**.
    - **"Select a default Firebase project for this directory:"** → Choose your `simplystyles` project from the list.
    - **"What do you want to use as your public directory?"** → Type `build/web` and press Enter. This is where Flutter will put your web files.
    - **"Configure as a single-page app (rewrite all urls to /index.html)?"** → Type `y` (for yes) and press Enter. This is important for Flutter web apps!
    - **"Set up automatic builds and deploys with GitHub?"** → Type `n` (for no) for now. You can set this up later if you want.

This will create two new files in your project: `firebase.json` and `.firebaserc`. I've already created these for you with the correct settings!

## Step 3: Build Your Flutter Web App

Next, you need to build the web version of your Flutter app. This will create the `build/web` folder that Firebase will upload.

1.  **Enable web support** (if you haven't already):

    ```bash
    flutter config --enable-web
    ```

2.  **Build the app**:
    ```bash
    flutter build web
    ```

This command will compile your Dart code to JavaScript and create all the necessary HTML and asset files in the `build/web` directory.

## Step 4: Deploy to Firebase! 🚀

This is the final step! You're about to go live.

1.  **Run the deploy command**:

    ```bash
    firebase deploy --only hosting
    ```

2.  **Wait for it to finish**. The terminal will show you the progress.

3.  **Done!** Once it's complete, you'll see a **Hosting URL**. It will look something like this:

    `https://simplystyles-your-project-id.web.app`

    You can click this link to see your live app! 🎉

## Step 5 (Optional): Connect a Custom Domain

Want a cooler URL like `www.simplystyles.app`? You can connect a custom domain you own.

1.  Go to the **Hosting** section of your Firebase project.
2.  Click **Add custom domain**.
3.  Follow the instructions to verify that you own the domain. This usually involves adding a TXT record to your domain's DNS settings.

## Summary of Commands

Here are all the commands you need in one place:

```bash
# 1. Install Firebase CLI (if you haven't already)
npm install -g firebase-tools

# 2. Login to Firebase
firebase login

# 3. Initialize Hosting
firebase init hosting

# 4. Build your Flutter web app
flutter build web

# 5. Deploy!
firebase deploy --only hosting
```

## Troubleshooting

- **"Firebase command not found"**: Make sure you've installed the Firebase CLI (`npm install -g firebase-tools`).
- **"404 Not Found" after deploying**: Make sure you set your public directory to `build/web` and configured it as a single-page app.
- **Changes not appearing**: Remember to run `flutter build web` every time you make changes to your app before deploying.

That's it! You've successfully hosted your Flutter web app on Firebase. Now you can share your creation with friends, family, and the world! 🌍✨

---

# Firebase Setup Checklist

1. Firebase Project

- Create a Firebase project in the Firebase Console (https://console.firebase.google.com/).
- Note the Project ID (you'll need it for GitHub secrets and hosting setup).

2. Web App Registration

- In Firebase Console > Project Settings > General > Your apps, register a Web app if not already done.
- Add the Firebase config to `lib/firebase_options.dart` (the FlutterFire CLI can generate this automatically: `flutterfire configure`).

3. Authentication

- Go to Firebase Console > Authentication > Sign-in method.
- Enable Google and Apple sign-in providers.
- Under Authorized domains, ensure `localhost` and your production domain (e.g., `example.web.app` or `example.firebaseapp.com`) are listed.
- If you use redirects with custom domains, add the domain to OAuth redirect domains.

4. Firestore & Storage

- Enable Firestore; set rules that match your security needs. For testing, you may use permissive rules but lock them before production.
- Enable Storage if needed and set appropriate rules.

5. Firebase Hosting

- In the Firebase Console, add a Hosting site and follow instructions to deploy the `build/web` from your Flutter web build.

6. Service account & GitHub Secrets (for CI/CD)

- Create a service account with the `Firebase Hosting Admin` (or `Editor`) role.
- Generate a JSON key for that service account.
- In your GitHub repository settings > Secrets > Actions, add:
  - `FIREBASE_SERVICE_ACCOUNT` : full JSON key contents (escaped as a single-line string)
  - `FIREBASE_PROJECT_ID` : your Firebase project id
  - `FIREBASE_TOKEN` : (optional) CI token created with `firebase login:ci` if you prefer token-based deploys

7. Test locally

- Run the app in Chrome/Edge and test Google sign-in flows.
- If popups are blocked, confirm redirect fallback behavior works.

8. Deploy

- Push to `main` to trigger the GitHub Action.
- Inspect the Action logs and Firebase Hosting site.

9. Production checklist

- Verify OAuth consent screen on GCP Console (for Google sign-in) is configured for production.
- Add privacy policy and terms of service as required by app stores.
- Configure Play Store / App Store signing and build pipelines.

---

If you want, I can:

- Run `flutterfire configure` in this repo (requires Firebase project access).
- Create the GCP service account and provide the JSON key (I can't create it from here, but I can give exact `gcloud` commands).
- Add a GitHub Action secret upload guide and sample `gcloud` commands to create the service account.

---

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

---

# Deep Linking & URL Shortening Configuration

## Overview

This document covers deep linking setup for SimplyStyles, including Firebase Dynamic Links, Android App Links, iOS Universal Links, and Bitly integration for branded short URLs.

## Firebase Dynamic Links

### Default Domain

```
simplysoph.page.link
```

### Configuration

- **Auto-provisioned**: Firebase automatically creates this domain
- **Free tier**: Unlimited links
- **Analytics**: Built-in click tracking
- **Deep linking**: Native app routing support

### Setup

1. Enable Dynamic Links in Firebase Console
2. No additional configuration needed for basic usage
3. Links automatically route to app or web fallback

## Application Links Configuration

### Android App Links

Add to Bitly or custom domain configuration:

```
https://simplysoph.page.link
https://simplysoph-66c78.web.app
https://simplysoph-66c78.firebaseapp.com
```

**android/app/src/main/AndroidManifest.xml:**

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="simplysoph.page.link" />
    <data android:scheme="https" android:host="simplysoph-66c78.web.app" />
</intent-filter>
```

### iOS Universal Links

Add to Bitly or custom domain configuration:

```
applinks:simplysoph.page.link
applinks:simplysoph-66c78.web.app
applinks:simplysoph-66c78.firebaseapp.com
```

**ios/Runner/Info.plist:**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>simplysoph</string>
        </array>
    </dict>
</array>
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:simplysoph.page.link</string>
    <string>applinks:simplysoph-66c78.web.app</string>
</array>
```

## Bitly Integration

### OAuth Redirect URIs

For Bitly OAuth authentication, configure these redirect URIs in your Bitly app settings:

**Primary:**

```
https://simplysoph-66c78.firebaseapp.com/__/auth/handler
```

**Additional:**

```
https://simplysoph-66c78.web.app/__/auth/handler
http://localhost/__/auth/handler
```

### Bitly Setup Steps

1. Go to https://app.bitly.com/settings/api/
2. Navigate to **OAuth Applications**
3. Create new application or edit existing
4. Add redirect URIs above
5. Copy Client ID and Client Secret

### API Access Token (Simpler Alternative)

If only using URL shortening (not OAuth):

1. Go to https://app.bitly.com/settings/api/
2. Generate Access Token
3. Store in Firebase environment config
4. No redirect URIs needed

### Application Links in Bitly

Add these domains to Bitly's "Allowed Domains" or "Application Links":

```
https://simplysoph.page.link
https://simplysoph-66c78.web.app
https://simplysoph-66c78.firebaseapp.com
```

## Custom Domain (Future)

### Recommended Setup

```
Domain: simplystyles.app
Short links: go.simplystyles.app
```

### Configuration

```
https://go.simplystyles.app
applinks:go.simplystyles.app
```

## Implementation Strategy

### Recommended Approach

1. **Firebase Dynamic Links**: Primary deep linking (free, native)
2. **Bitly**: Marketing campaigns and branded short URLs
3. **Custom Domain**: Future branding upgrade

### Use Cases

**Firebase Dynamic Links:**

- In-app sharing (outfit recommendations)
- Email notifications (password reset, welcome)
- Push notifications
- Social media posts from app

**Bitly:**

- Marketing campaigns
- Influencer tracking
- A/B testing different links
- Analytics and click tracking
- Branded short URLs for external marketing

## Flutter Dependencies

### pubspec.yaml

```yaml
dependencies:
  firebase_dynamic_links: ^5.5.0 # Firebase Dynamic Links
  uni_links: ^0.5.1 # Deep link handling
  url_launcher: ^6.3.0 # Open URLs

  # Optional: Bitly API client
  http: ^1.2.0 # For Bitly API calls
```

## Code Implementation

### Firebase Dynamic Links Service

**lib/services/dynamic_links_service.dart:**

```dart
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinksService {
  static const String _dynamicLinkDomain = 'simplysoph.page.link';
  static const String _webUrl = 'https://simplysoph-66c78.web.app';

  Future<String> createOutfitLink(String outfitId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://$_dynamicLinkDomain',
      link: Uri.parse('$_webUrl/outfit/$outfitId'),
      androidParameters: const AndroidParameters(
        packageName: 'com.simplysoph.simplystyles',
        minimumVersion: 1,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.simplysoph.simplystyles',
        minimumVersion: '1.0.0',
        appStoreId: 'YOUR_APP_STORE_ID',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out this outfit!',
        description: 'Discover this style on SimplyStyles',
        imageUrl: Uri.parse('$_webUrl/assets/share-image.png'),
      ),
    );

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance
        .buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }

  Future<void> handleDynamicLink() async {
    // Handle link when app is opened
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(initialLink);

    // Handle link when app is in background
    FirebaseDynamicLinks.instance.onLink.listen(_handleDeepLink);
  }

  void _handleDeepLink(PendingDynamicLinkData? linkData) {
    if (linkData == null) return;
    final Uri deepLink = linkData.link;
    // Route to appropriate screen based on deepLink path
  }
}
```

### Bitly Service (Optional)

**lib/services/bitly_service.dart:**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BitlyService {
  static const String _apiUrl = 'https://api-ssl.bitly.com/v4';
  final String _accessToken;

  BitlyService(this._accessToken);

  Future<String> shortenUrl(String longUrl) async {
    final response = await http.post(
      Uri.parse('$_apiUrl/shorten'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'long_url': longUrl}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['link'];
    }
    throw Exception('Failed to shorten URL: ${response.body}');
  }
}
```

## Environment Configuration

### Firebase Functions Config

Store Bitly token securely:

```bash
firebase functions:config:set bitly.token="YOUR_BITLY_ACCESS_TOKEN"
```

### Flutter Environment Variables

**lib/config/env.dart:**

```dart
class Env {
  static const String bitlyToken = String.fromEnvironment(
    'BITLY_TOKEN',
    defaultValue: '',
  );
}
```

## Security Considerations

1. **Never commit API tokens** to version control
2. **Use Firebase Functions** for server-side Bitly API calls
3. **Validate deep links** before routing in app
4. **Implement rate limiting** on link creation
5. **Monitor link analytics** for abuse

## Testing

### Test Deep Links

**Android:**

```bash
adb shell am start -W -a android.intent.action.VIEW -d "https://simplysoph.page.link/test"
```

**iOS:**

```bash
xcrun simctl openurl booted "https://simplysoph.page.link/test"
```

### Test Bitly Integration

```dart
final bitly = BitlyService('YOUR_TOKEN');
final shortUrl = await bitly.shortenUrl('https://simplysoph-66c78.web.app/outfit/123');
print(shortUrl); // https://bit.ly/xxxxx
```

## Analytics & Monitoring

### Firebase Dynamic Links Analytics

- Click tracking (automatic)
- Platform breakdown (iOS/Android/Web)
- Geographic data
- Referrer information

### Bitly Analytics

- Click counts
- Geographic data
- Referrer tracking
- Custom campaign parameters

## Cost Estimates

### Firebase Dynamic Links

- **Free**: Unlimited links and clicks
- **Analytics**: Included

### Bitly

- **Free Tier**: 50 links/month, basic analytics
- **Starter**: $29/month, 1,500 links/month
- **Premium**: $199/month, unlimited links, advanced analytics
- **Enterprise**: Custom pricing

## Next Steps

1. ✅ Document configuration (this file)
2. ⬜ Enable Firebase Dynamic Links in console
3. ⬜ Implement DynamicLinksService
4. ⬜ Add deep link handling to main.dart
5. ⬜ Test deep links on Android/iOS
6. ⬜ (Optional) Set up Bitly account
7. ⬜ (Optional) Implement BitlyService
8. ⬜ Configure custom domain (future)

## References

- [Firebase Dynamic Links](https://firebase.google.com/docs/dynamic-links)
- [Bitly API Documentation](https://dev.bitly.com/)
- [Android App Links](https://developer.android.com/training/app-links)
- [iOS Universal Links](https://developer.apple.com/ios/universal-links/)
