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
