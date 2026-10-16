# CI/CD

Pipeline overview, jobs, artifacts, and branch behavior.

### Consolidated Sources

- CI_CD_SETUP.md
- CICD_INDEX.md
- CICD_SUMMARY.md
- WORKFLOW_DIAGRAM.md

---

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
# Navigate to your local clone
cd SimplySoph-SimplyStyles

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

---

# 📚 CI/CD Documentation Index

Welcome to the SimplyStyles CI/CD documentation! This index will help you find the right guide for your needs.

---

## 🚀 Getting Started

### New to CI/CD?

1. **Start here**: [QUICK_DEPLOY.md](QUICK_DEPLOY.md) - 5-minute setup
2. **Then read**: [WORKFLOW_DIAGRAM.md](WORKFLOW_DIAGRAM.md) - Visual overview
3. **Reference**: [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Step-by-step

### Already familiar with CI/CD?

- Jump to: [CI_CD_SETUP.md](CI_CD_SETUP.md) - Complete technical guide
- Review: [CICD_SUMMARY.md](CICD_SUMMARY.md) - Implementation details

---

## 📖 Documentation Files

### 1. [QUICK_DEPLOY.md](QUICK_DEPLOY.md)

**Purpose**: Fast-track deployment guide  
**Best for**: Quick reference, daily workflow  
**Time**: 5 minutes  
**Contains**:

- One-time setup commands
- Daily workflow
- Quick troubleshooting
- Essential URLs

---

### 2. [CI_CD_SETUP.md](CI_CD_SETUP.md)

**Purpose**: Complete setup guide  
**Best for**: First-time setup, troubleshooting  
**Time**: 15-20 minutes  
**Contains**:

- Detailed prerequisites
- Step-by-step Firebase service account creation
- GitHub secrets configuration
- Local testing instructions
- Comprehensive troubleshooting

---

### 3. [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)

**Purpose**: Interactive checklist  
**Best for**: Ensuring nothing is missed  
**Time**: Follow along during setup  
**Contains**:

- Pre-deployment tasks
- Testing checklist
- Deployment steps
- Post-deployment verification
- Success criteria

---

### 4. [CICD_SUMMARY.md](CICD_SUMMARY.md)

**Purpose**: Implementation overview  
**Best for**: Understanding what was built  
**Time**: 10 minutes read  
**Contains**:

- What's been implemented
- Workflow behavior
- Build artifacts info
- Next steps and enhancements
- Success checklist

---

### 5. [WORKFLOW_DIAGRAM.md](WORKFLOW_DIAGRAM.md)

**Purpose**: Visual pipeline explanation  
**Best for**: Understanding the flow  
**Time**: 5 minutes  
**Contains**:

- Complete pipeline flow diagram
- Branch-specific behavior
- Security flow
- Parallel execution visualization
- Failure handling

---

### 6. [CICD_INDEX.md](CICD_INDEX.md)

**Purpose**: This file - navigation hub  
**Best for**: Finding the right documentation  
**Time**: 2 minutes  
**Contains**:

- Documentation overview
- Quick navigation
- Use case guides

---

## 🎯 Use Case Guide

### "I want to deploy my app NOW"

→ [QUICK_DEPLOY.md](QUICK_DEPLOY.md)

### "I'm setting up CI/CD for the first time"

→ [CI_CD_SETUP.md](CI_CD_SETUP.md) + [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)

### "I want to understand how it works"

→ [WORKFLOW_DIAGRAM.md](WORKFLOW_DIAGRAM.md) + [CICD_SUMMARY.md](CICD_SUMMARY.md)

### "Something broke, help!"

→ [CI_CD_SETUP.md](CI_CD_SETUP.md) → Troubleshooting section

### "I need a quick command reference"

→ [QUICK_DEPLOY.md](QUICK_DEPLOY.md) → Quick Commands section

### "What did you actually implement?"

→ [CICD_SUMMARY.md](CICD_SUMMARY.md)

---

## 🛠️ Scripts & Tools

### Windows Users

```cmd
scripts\setup-cicd.bat
```

Automated setup script for Windows

### Mac/Linux Users

```bash
bash scripts/create_firebase_service_account.sh simplysoph-66c78 github-actions-deploy
```

Bash script for service account creation

---

## 📁 Workflow Files

### Main Workflow

`.github/workflows/firebase-hosting-deploy.yml`

- Tests, builds, and deploys on push to main
- Runs tests and builds on PRs

### PR Preview Workflow

`.github/workflows/pr-preview.yml`

- Creates temporary preview deployments for PRs
- Auto-expires after 7 days

---

## 🔗 Important URLs

| Resource         | URL                                                                               |
| ---------------- | --------------------------------------------------------------------------------- |
| Live App         | https://simplysoph-66c78.web.app                                                  |
| Firebase Console | https://console.firebase.google.com/project/simplysoph-66c78                      |
| GitHub Actions   | https://github.com/YOUR_USERNAME/SimplySoph-SimplyStyles/actions                  |
| GitHub Secrets   | https://github.com/YOUR_USERNAME/SimplySoph-SimplyStyles/settings/secrets/actions |

---

## 📊 Quick Reference

### Essential Commands

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Build web
flutter build web --release

# Build Android
flutter build apk --release

# Check gcloud auth
gcloud auth list

# List Firebase projects
firebase projects:list
```

### Required GitHub Secret

- **Name**: `FIREBASE_SERVICE_ACCOUNT`
- **Value**: Contents of `github-actions-key.json`

### Firebase Project

- **ID**: `simplysoph-66c78`
- **Service Account**: `github-actions-deploy@simplysoph-66c78.iam.gserviceaccount.com`

---

## 🎓 Learning Path

### Beginner

1. Read [QUICK_DEPLOY.md](QUICK_DEPLOY.md)
2. Follow [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)
3. Review [WORKFLOW_DIAGRAM.md](WORKFLOW_DIAGRAM.md)

### Intermediate

1. Study [CI_CD_SETUP.md](CI_CD_SETUP.md)
2. Review [CICD_SUMMARY.md](CICD_SUMMARY.md)
3. Explore workflow files in `.github/workflows/`

### Advanced

1. Customize workflows in `.github/workflows/`
2. Add enhancements from [CICD_SUMMARY.md](CICD_SUMMARY.md) → Next Steps
3. Implement additional CI/CD features

---

## ✅ Quick Status Check

Before you start, verify:

- [ ] GitHub repository exists
- [ ] Firebase project created (`simplysoph-66c78`)
- [ ] `gcloud` CLI installed
- [ ] `firebase` CLI installed
- [ ] Git configured locally

---

## 🆘 Need Help?

1. **Check troubleshooting**: [CI_CD_SETUP.md](CI_CD_SETUP.md) → Troubleshooting
2. **Review checklist**: [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)
3. **Verify setup**: [QUICK_DEPLOY.md](QUICK_DEPLOY.md) → Troubleshooting
4. **Check workflow logs**: GitHub Actions tab

---

## 🎉 Success Indicators

You'll know everything is working when:

- ✅ GitHub Actions badge shows "passing"
- ✅ App is live at https://simplysoph-66c78.web.app
- ✅ PRs get preview URLs automatically
- ✅ Build artifacts are downloadable
- ✅ Tests run on every push

---

**Ready to start?** → [QUICK_DEPLOY.md](QUICK_DEPLOY.md)

**Need details?** → [CI_CD_SETUP.md](CI_CD_SETUP.md)

**Want to understand?** → [WORKFLOW_DIAGRAM.md](WORKFLOW_DIAGRAM.md)

---

# CI/CD Implementation Summary

## ✅ What's Been Set Up

### 1. Enhanced GitHub Actions Workflows

#### Main Workflow: `firebase-hosting-deploy.yml`

- **Triggers**: Push to `main` or Pull Requests
- **Jobs**:
  - `test`: Runs Flutter tests with coverage analysis
  - `build-web`: Builds web version and uploads artifact
  - `build-android`: Builds Android APK and uploads artifact
  - `deploy`: Deploys to Firebase Hosting (main branch only)

#### PR Preview Workflow: `pr-preview.yml`

- **Triggers**: Pull Request opened/updated
- **Purpose**: Creates temporary preview deployments (7-day expiry)
- **Benefit**: Review changes before merging

### 2. Automated Testing & Quality Checks

- ✅ Code analysis with `flutter analyze`
- ✅ Unit and widget tests with coverage
- ✅ Coverage reports uploaded to Codecov (optional)

### 3. Build Artifacts

- ✅ Web build (ready for Firebase Hosting)
- ✅ Android APK (downloadable from Actions)
- ✅ Artifacts stored for 90 days by default

### 4. Documentation Created

- `CI_CD_SETUP.md` - Complete setup guide
- `DEPLOYMENT_CHECKLIST.md` - Step-by-step checklist
- `CICD_SUMMARY.md` - This file
- Updated `README.md` with badges and deployment info

### 5. Helper Scripts

- `scripts/create_firebase_service_account.sh` - Bash script (existing)
- `scripts/setup-cicd.bat` - Windows batch script (new)

---

## 🚀 What You Need to Do

### Step 1: Create Firebase Service Account

**Option A - Windows (Easiest):**

```cmd
cd SimplySoph-SimplyStyles
scripts\setup-cicd.bat
```

**Option B - Git Bash/Linux:**

```bash
bash scripts/create_firebase_service_account.sh simplysoph-66c78 github-actions-deploy
```

**Option C - Manual Commands:**

```bash
gcloud auth login
gcloud config set project simplysoph-66c78

gcloud iam service-accounts create github-actions-deploy \
  --display-name="GitHub Actions Deploy" \
  --project=simplysoph-66c78

gcloud projects add-iam-policy-binding simplysoph-66c78 \
  --member="serviceAccount:github-actions-deploy@simplysoph-66c78.iam.gserviceaccount.com" \
  --role="roles/firebasehosting.admin"

gcloud iam service-accounts keys create github-actions-key.json \
  --iam-account=github-actions-deploy@simplysoph-66c78.iam.gserviceaccount.com \
  --project=simplysoph-66c78
```

### Step 2: Add GitHub Secret

1. Open the generated `github-actions-key.json`
2. Copy the **entire** JSON content
3. Go to: https://github.com/YOUR_USERNAME/SimplySoph-SimplyStyles/settings/secrets/actions
4. Click **New repository secret**
5. Name: `FIREBASE_SERVICE_ACCOUNT`
6. Value: Paste the JSON
7. Click **Add secret**

### Step 3: Push to GitHub

```bash
git add .
git commit -m "feat: implement CI/CD pipeline with automated testing and deployment"
git push origin main
```

### Step 4: Monitor Deployment

1. Go to: https://github.com/YOUR_USERNAME/SimplySoph-SimplyStyles/actions
2. Watch the workflow run
3. Verify all jobs complete successfully
4. Check live app: https://simplysoph-66c78.web.app

---

## 📊 Workflow Behavior

### On Pull Request:

```
PR opened/updated
    ↓
Run tests → Build web → Build Android
    ↓
Deploy preview channel (temporary URL)
    ↓
Comment on PR with preview link
```

### On Push to Main:

```
Push to main
    ↓
Run tests → Build web → Build Android
    ↓
Deploy to production (live site)
    ↓
Artifacts available for download
```

---

## 🔍 What Gets Checked

### Code Quality

- ✅ Dart analysis (linting)
- ✅ No analyzer warnings/errors
- ✅ Code formatting (optional: add `flutter format --set-exit-if-changed`)

### Testing

- ✅ All unit tests pass
- ✅ All widget tests pass
- ✅ Code coverage generated
- ✅ Coverage report uploaded

### Build Verification

- ✅ Web build succeeds
- ✅ Android APK builds
- ✅ No build errors
- ✅ Assets properly bundled

---

## 📦 Build Artifacts

After each successful workflow run, you can download:

1. **web-build** - Complete web application

   - Path: `build/web/`
   - Use: Manual deployment or inspection

2. **android-apk** - Release APK
   - Path: `build/app/outputs/flutter-apk/app-release.apk`
   - Use: Testing or distribution

---

## 🛠️ Troubleshooting

### "Service account not found"

```bash
gcloud iam service-accounts list --project=simplysoph-66c78
```

### "Permission denied"

```bash
gcloud projects get-iam-policy simplysoph-66c78 \
  --flatten="bindings[].members" \
  --filter="bindings.members:github-actions-deploy"
```

### "Tests failing in CI but pass locally"

- Check Flutter version: `flutter --version`
- Verify dependencies: `flutter pub get`
- Check for environment-specific issues

### "Deployment failed"

- Verify `FIREBASE_SERVICE_ACCOUNT` secret is set
- Check service account has `firebasehosting.admin` role
- Ensure Firebase project ID matches: `simplysoph-66c78`

---

## 🎯 Next Steps (Optional Enhancements)

### 1. Add Code Coverage Badge

```markdown
[![codecov](https://codecov.io/gh/YOUR_USERNAME/SimplySoph-SimplyStyles/branch/main/graph/badge.svg)](https://codecov.io/gh/YOUR_USERNAME/SimplySoph-SimplyStyles)
```

### 2. iOS Build (Requires macOS Runner)

```yaml
build-ios:
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
    - run: flutter build ios --release --no-codesign
```

### 3. Automated Release Notes

```yaml
- name: Generate Release Notes
  uses: release-drafter/release-drafter@v5
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 4. Slack/Discord Notifications

```yaml
- name: Notify Deployment
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### 5. Dependabot for Dependencies

Create `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "pub"
    directory: "/"
    schedule:
      interval: "weekly"
```

---

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Firebase Hosting GitHub Action](https://github.com/FirebaseExtended/action-hosting-deploy)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Google Cloud IAM](https://cloud.google.com/iam/docs)

---

## ✅ Success Checklist

- [ ] Service account created
- [ ] GitHub secret configured
- [ ] Workflow file committed
- [ ] First deployment successful
- [ ] Live app accessible
- [ ] PR preview working
- [ ] Build artifacts downloadable
- [ ] Tests passing in CI

---

**Status**: Ready to deploy! 🎉

**Live URL**: https://simplysoph-66c78.web.app

**GitHub Actions**: https://github.com/YOUR_USERNAME/SimplySoph-SimplyStyles/actions

---

# CI/CD Workflow Diagram

## 📊 Complete Pipeline Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     Developer Workflow                          │
└─────────────────────────────────────────────────────────────────┘

    Developer writes code
           ↓
    git commit & push
           ↓
    ┌──────────────────┐
    │  GitHub Detects  │
    │   Push/PR Event  │
    └──────────────────┘
           ↓
    ┌──────────────────────────────────────────────────────────┐
    │              GitHub Actions Triggered                    │
    └──────────────────────────────────────────────────────────┘
           ↓
    ┌──────────────────────────────────────────────────────────┐
    │  JOB 1: TEST                                             │
    │  ✓ Setup Flutter                                         │
    │  ✓ Install dependencies (flutter pub get)               │
    │  ✓ Analyze code (flutter analyze)                       │
    │  ✓ Run tests (flutter test --coverage)                  │
    │  ✓ Upload coverage report                               │
    └──────────────────────────────────────────────────────────┘
           ↓
    ┌──────────────────────────────────────────────────────────┐
    │  JOB 2: BUILD WEB (runs in parallel after tests pass)   │
    │  ✓ Setup Flutter                                         │
    │  ✓ Install dependencies                                  │
    │  ✓ Build web (flutter build web --release)              │
    │  ✓ Upload web-build artifact                            │
    └──────────────────────────────────────────────────────────┘
           ↓
    ┌──────────────────────────────────────────────────────────┐
    │  JOB 3: BUILD ANDROID (runs in parallel after tests)    │
    │  ✓ Setup Java 17                                         │
    │  ✓ Setup Flutter                                         │
    │  ✓ Install dependencies                                  │
    │  ✓ Build APK (flutter build apk --release)              │
    │  ✓ Upload android-apk artifact                          │
    └──────────────────────────────────────────────────────────┘
           ↓
    ┌──────────────────────────────────────────────────────────┐
    │  JOB 4: DEPLOY (only on main branch push)               │
    │  ✓ Download web-build artifact                          │
    │  ✓ Authenticate with Firebase                           │
    │  ✓ Deploy to Firebase Hosting                           │
    │  ✓ Live at: https://simplysoph-66c78.web.app           │
    └──────────────────────────────────────────────────────────┘
           ↓
    ┌──────────────────┐
    │   🎉 Success!    │
    │  App is Live     │
    └──────────────────┘
```

---

## 🔀 Branch-Specific Behavior

### Pull Request Flow

```
Feature Branch
    ↓
Create PR
    ↓
┌─────────────────────┐
│  Automated Checks   │
│  ✓ Tests            │
│  ✓ Build Web        │
│  ✓ Build Android    │
│  ✓ Preview Deploy   │ ← Creates temporary URL
└─────────────────────┘
    ↓
PR Comment with preview link
    ↓
Review & Approve
    ↓
Merge to main
    ↓
Production Deploy
```

### Main Branch Flow

```
Push to main
    ↓
┌─────────────────────┐
│  Full Pipeline      │
│  ✓ Tests            │
│  ✓ Build Web        │
│  ✓ Build Android    │
│  ✓ Deploy Live      │ ← Production deployment
└─────────────────────┘
    ↓
Live at simplysoph-66c78.web.app
```

---

## 🔐 Security Flow

```
GitHub Actions Runner
    ↓
Reads secret: FIREBASE_SERVICE_ACCOUNT
    ↓
Creates temporary service-account.json
    ↓
Authenticates with Firebase
    ↓
Deploys using service account credentials
    ↓
Deletes temporary credentials
```

---

## 📦 Artifact Storage

```
Build Completes
    ↓
┌─────────────────────────────────┐
│  Artifacts Stored (90 days)    │
│                                 │
│  📁 web-build/                  │
│     └─ Complete web app         │
│                                 │
│  📁 android-apk/                │
│     └─ app-release.apk          │
└─────────────────────────────────┘
    ↓
Available for download in Actions tab
```

---

## ⏱️ Typical Timeline

```
Event: Push to main
    ↓
0:00 - Workflow triggered
0:30 - Tests complete (✓)
1:00 - Web build complete (✓)
1:30 - Android build complete (✓)
2:00 - Deployment starts
2:30 - Live on Firebase (✓)

Total: ~2-3 minutes
```

---

## 🎯 Decision Points

```
                    Push Event
                        ↓
                Is it main branch?
                   /        \
                 YES         NO
                  ↓           ↓
            Deploy Live    Skip Deploy
                  ↓           ↓
         Production URL   Artifacts Only
```

```
                  Tests Running
                        ↓
                  All Pass?
                   /        \
                 YES         NO
                  ↓           ↓
            Continue      Stop Pipeline
            Pipeline      Show Errors
```

---

## 🔄 Continuous Integration Loop

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Code → Test → Build → Deploy → Monitor            │
│    ↑                                    ↓           │
│    └────────── Fix Issues ──────────────┘           │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 📊 Parallel Execution

```
        Tests Complete
              ↓
    ┌─────────┴─────────┐
    ↓                   ↓
Build Web          Build Android
    ↓                   ↓
Upload Artifact    Upload Artifact
    └─────────┬─────────┘
              ↓
         Deploy (if main)
```

---

## 🚨 Failure Handling

```
Step Fails
    ↓
Pipeline Stops
    ↓
GitHub sends notification
    ↓
Developer reviews logs
    ↓
Fix issue locally
    ↓
Push fix
    ↓
Pipeline retries
```

---

## 📈 Success Metrics

```
✅ Test Coverage: Tracked
✅ Build Time: Monitored
✅ Deployment Success Rate: 100%
✅ Artifacts: Preserved
✅ Preview URLs: Generated for PRs
```

---

## 🔗 Integration Points

```
GitHub Repository
    ↓
GitHub Actions (CI/CD)
    ↓
Firebase Hosting (Deployment)
    ↓
Live Application
    ↓
End Users
```

---

**Visual Summary**: Every push triggers automated quality checks, builds, and deployment - ensuring your app is always tested, built correctly, and deployed reliably.
