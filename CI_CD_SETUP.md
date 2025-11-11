# CI/CD Setup Guide

## Overview
This guide walks you through setting up automated testing, building, and deployment for SimplyStyles using GitHub Actions and Firebase Hosting.

## Prerequisites
- GitHub repository with push access
- Firebase project: `simplysoph-66c78`
- Google Cloud SDK (`gcloud`) installed locally
- Firebase CLI installed: `npm install -g firebase-tools`

---

## Step 1: Create Firebase Service Account

### Option A: Using the provided script (Recommended)

```bash
# Navigate to your project
cd c:\Users\saulp\AppData\Workspace\GitHub\SimplySoph-SimplyStyles

# Run the script (use Git Bash on Windows)
bash scripts/create_firebase_service_account.sh simplysoph-66c78 github-actions-deploy
```

### Option B: Manual gcloud commands

```bash
# 1. Authenticate with Google Cloud
gcloud auth login

# 2. Set your project
gcloud config set project simplysoph-66c78

# 3. Create service account
gcloud iam service-accounts create github-actions-deploy \
  --display-name="GitHub Actions Deploy" \
  --project=simplysoph-66c78

# 4. Grant Firebase Hosting Admin role
gcloud projects add-iam-policy-binding simplysoph-66c78 \
  --member="serviceAccount:github-actions-deploy@simplysoph-66c78.iam.gserviceaccount.com" \
  --role="roles/firebasehosting.admin"

# 5. Create and download key
gcloud iam service-accounts keys create github-actions-key.json \
  --iam-account=github-actions-deploy@simplysoph-66c78.iam.gserviceaccount.com \
  --project=simplysoph-66c78

# 6. Display the key (copy this output)
cat github-actions-key.json
```

---

## Step 2: Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

### Required Secret:

**Name:** `FIREBASE_SERVICE_ACCOUNT`  
**Value:** Paste the entire contents of `github-actions-key.json`

```json
{
  "type": "service_account",
  "project_id": "simplysoph-66c78",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "github-actions-deploy@simplysoph-66c78.iam.gserviceaccount.com",
  ...
}
```

---

## Step 3: Verify Firebase Configuration

Check that your Firebase project is properly configured:

```bash
# Login to Firebase
firebase login

# List your projects
firebase projects:list

# Verify current project
firebase use

# Should show: simplysoph-66c78
```

---

## Step 4: Test Locally (Optional)

Before pushing, test the workflow steps locally:

```bash
# Run tests
flutter test --coverage

# Run analyzer
flutter analyze

# Build web
flutter build web --release

# Build Android APK
flutter build apk --release
```

---

## Step 5: Trigger the Workflow

### Push to main branch:
```bash
git add .
git commit -m "feat: enable CI/CD pipeline"
git push origin main
```

### Or create a Pull Request:
```bash
git checkout -b feature/test-cicd
git add .
git commit -m "test: verify CI/CD pipeline"
git push origin feature/test-cicd
# Create PR on GitHub
```

---

## Workflow Behavior

### On Pull Request:
- ✅ Run tests with coverage
- ✅ Analyze code
- ✅ Build web version
- ✅ Build Android APK
- ❌ Does NOT deploy

### On Push to Main:
- ✅ Run tests with coverage
- ✅ Analyze code
- ✅ Build web version
- ✅ Build Android APK
- ✅ **Deploy to Firebase Hosting**

---

## Troubleshooting

### Issue: "Service account not found"
```bash
# List service accounts
gcloud iam service-accounts list --project=simplysoph-66c78
```

### Issue: "Permission denied"
```bash
# Verify IAM roles
gcloud projects get-iam-policy simplysoph-66c78 \
  --flatten="bindings[].members" \
  --filter="bindings.members:github-actions-deploy@simplysoph-66c78.iam.gserviceaccount.com"
```

### Issue: "Tests failing in CI"
- Check test output in GitHub Actions logs
- Run `flutter test` locally to reproduce
- Ensure all dependencies are in `pubspec.yaml`

### Issue: "Build artifacts not found"
- Verify the build path matches: `build/web/` and `build/app/outputs/flutter-apk/`
- Check Flutter version compatibility

---

## Viewing Results

### GitHub Actions:
- Go to: **Actions** tab in your repository
- Click on the latest workflow run
- View logs for each job (test, build-web, build-android, deploy)

### Firebase Hosting:
- Visit: https://console.firebase.google.com/project/simplysoph-66c78/hosting
- Your app will be live at: https://simplysoph-66c78.web.app

### Build Artifacts:
- In GitHub Actions, click on a completed workflow
- Scroll to **Artifacts** section
- Download `web-build` or `android-apk`

---

## Next Steps

1. **Add code coverage badge** to README.md
2. **Set up Firebase preview channels** for PR deployments
3. **Configure iOS builds** (requires macOS runner)
4. **Add automated release notes** generation
5. **Set up Dependabot** for dependency updates

---

## Quick Reference Commands

```bash
# Check gcloud auth
gcloud auth list

# Switch Firebase project
firebase use simplysoph-66c78

# View GitHub Actions locally (using act)
act -l

# Clean Flutter build
flutter clean && flutter pub get

# Run specific test file
flutter test test/auth_service_test.dart
```
