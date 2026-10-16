# Deployment

Guidance for staging/production deploys and environment management.

> **Warning:** Firebase project `simplysoph-66c78` is shared with the live SimplySoph website. Its default Hosting site, Firestore rules and Storage rules belong to that website, so `firebase deploy`, `firebase deploy --only hosting` and the `scripts/deploy*` scripts would overwrite it. Until SimplyStyles has its own Hosting site or project, deploy Cloud Functions only, using the manual job in `.github/workflows/firebase-hosting-deploy.yml` (see [Cloud Functions deploy](#cloud-functions-deploy)). The older sections further down (service account JSON keys, `FIREBASE_SERVICE_ACCOUNT`, hosting deploys) are kept for history and do not apply.

### Consolidated Sources

- DEPLOYMENT_CHECKLIST.md
- DEPLOY_NOW.md
- FIREBASE_HOSTING_GUIDE.md
- DEPLOY_STORAGE_RULES.md

## Cloud Functions deploy

### Own codebase: `simplystyles`

`firebase.json` puts this app's functions in their own Firebase codebase:

```json
"functions": [{ "source": "functions", "codebase": "simplystyles" }]
```

The Firebase CLI records each function's codebase and, on deploy, only creates, updates or deletes functions in the codebases being deployed ([Organize multiple functions: managing multiple repositories](https://firebase.google.com/docs/functions/organize-functions#managing_multiple_repositories)). So:

- The website (`HybridCloudWorks/SimplySoph-SimplySoph`) deploys its `default` codebase with `firebase deploy --only functions --force`. That only deletes stale functions in `default`, so it leaves the `simplystyles` functions alone.
- This repo deploys with `firebase deploy --only functions:simplystyles`, which can't touch the website's functions (`api`, `setAdminClaim`, `onBlogPostWrite`, `onVideoWrite`, `onPhotoAlbumWrite`, `onContactMessageCreate`).
- Function names must stay unique across the project. A function with the same name in both codebases is taken over by whichever repo deploys it last.
- The deploy job doesn't pass `--force`. If you remove a function from `functions/index.js`, the deploy stops instead of deleting it. To delete one on purpose, run `firebase functions:delete <name> --project simplysoph-66c78`.

The codebase split protects against the CLI deleting the other repo's functions. It is not an IAM boundary: Google Cloud roles can't be scoped to a codebase, so the deploy identity could still change any function in the project. Its Workload Identity Federation provider limits who can use it (see below).

### Runtime and dependencies

- **Node.js 22** (`functions/package.json` `engines`). Cloud Run functions decommissions Node.js 20 on 2026-10-30; after that, functions on it can't be deployed or updated ([runtime support](https://cloud.google.com/functions/docs/runtime-support)). `firebase-admin` 14 also needs Node.js 22 or later.
- **`firebase-functions` 7.3.2**, the first 7.x release whose peer range accepts `firebase-admin` 14, and **`firebase-admin` 14.5.0**. `firebase-admin` 14 removed the namespaced API (`admin.firestore()`, `admin.storage()`), so `functions/index.js` uses `firebase-admin/app`, `firebase-admin/firestore` and `firebase-admin/storage`.
- All 9 functions are 2nd gen, in `us-central1`.

### CI checks

The `functions` job in `.github/workflows/firebase-hosting-deploy.yml` runs on every pull request and every push to `main`, without secrets:

1. `npm ci`
2. `npm run lint` (`node --check index.js`)
3. `npm test`, if a test script exists (there are no function tests yet)
4. A load check: the same function discovery `firebase deploy` runs (`firebase-functions` with `FUNCTIONS_MANIFEST_OUTPUT_PATH`), against a stub project. It fails unless exactly the 9 expected functions load, as 2nd-gen functions in `us-central1` with the expected trigger types.

### Deploying

Run **Actions → CI/CD - Build, Test & Deploy → Run workflow** on `main`, or:

```bash
gh workflow run firebase-hosting-deploy.yml --repo HybridCloudWorks/SimplySoph-SimplyStyles --ref main
```

The `deploy-functions` job runs only for manual runs on `main`, after the `test` and `functions` jobs pass. It:

1. stops with an error if the repository variable `GCP_WORKLOAD_IDENTITY_PROVIDER` or `GCP_SERVICE_ACCOUNT` is missing;
2. signs in to Google Cloud with GitHub OIDC and Workload Identity Federation (`google-github-actions/auth`), with no stored key or token;
3. runs `firebase deploy --only functions:simplystyles --project simplysoph-66c78 --non-interactive` with firebase-tools 15.32.1.

It never deploys hosting, Firestore rules or Storage rules.

### One-time setup for keyless deploys

A project Owner runs [`scripts/setup-functions-deploy-identity.ps1`](../scripts/setup-functions-deploy-identity.ps1) once, with PowerShell 7.2 or later and `gcloud` and `gh` signed in:

```powershell
pwsh ./scripts/setup-functions-deploy-identity.ps1 -WhatIf            # preview, changes nothing
pwsh ./scripts/setup-functions-deploy-identity.ps1 -SetRepoVariables  # apply and set the repo variables
```

Without `-SetRepoVariables` it prints the `gh variable set` commands instead. It checks the current state before each step, skips what is already done, and prints undo commands for what it changed. It creates or reuses:

| Item | Value |
| --- | --- |
| Workload identity provider | `simplystyles-functions` in the existing `github-actions` pool (project number 424903425639). It accepts only GitHub tokens with `repository_id` 1087437215, `repository_owner_id` 312844660 and `ref` `refs/heads/main`. The website's `github-actions-provider` and its bindings are not changed. |
| Deploy service account | `simplystyles-functions-deploy@simplysoph-66c78.iam.gserviceaccount.com` |
| Project roles | `roles/cloudfunctions.admin`, `roles/cloudscheduler.admin`, `roles/firebase.viewer`, `roles/serviceusage.serviceUsageConsumer` |
| Service Account User | On `424903425639-compute@developer.gserviceaccount.com` (the functions runtime and Cloud Build service account) and `simplysoph-66c78@appspot.gserviceaccount.com` |
| Impersonation | `roles/iam.workloadIdentityUser` on the deploy service account for `principalSet://iam.googleapis.com/projects/424903425639/locations/global/workloadIdentityPools/github-actions/attribute.repository_id/1087437215` |
| Google-managed identities | `roles/run.invoker` for the compute service account (missing today), and the Cloud Storage, Pub/Sub and Eventarc bindings if they are missing |
| APIs | The functions deploy APIs, if any are disabled |
| Repository variables | `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT` |

Why these roles:

- **Cloud Functions Admin, not Developer.** Before creating new callable or HTTPS functions, firebase-tools checks for `cloudfunctions.functions.setIamPolicy`, then makes callables public with `run.services.setIamPolicy` ([Cloud Run: allowing public access](https://cloud.google.com/run/docs/authenticating/public)). Cloud Functions Admin has both, so Cloud Run Admin isn't needed.
- **Cloud Scheduler Admin** creates and updates the job for `vortex_updateDailyTrends`.
- **Firebase Viewer** (read-only) covers the project config, the storage trigger's bucket and the CLI's pre-deploy checks.
- **Service Usage Consumer** lets the CLI check that the APIs are enabled.
- **Service Account User** on the runtime and Cloud Build service account is the documented deployer requirement ([Cloud Functions IAM roles](https://cloud.google.com/functions/docs/reference/iam/roles)). firebase-tools also checks it on the App Engine default service account before any functions deploy.
- **No Artifact Registry Writer.** Cloud Build pushes the images, as the build service account. The `gcf-artifacts` repository in `us-central1` already has the `firebase-functions-cleanup` policy, so the CLI doesn't need to set one.
- **Google-managed identities.** On the first 2nd-gen deploy of a codebase, firebase-tools checks these project bindings and tries to add missing ones itself, which would need Project IAM Admin. The script adds them instead.

After the first green keyless deploy, delete the old token secret:

```bash
gh secret delete FIREBASE_TOKEN --repo HybridCloudWorks/SimplySoph-SimplyStyles
```

---

# Deployment Checklist

## Pre-Deployment Setup

### ☐ Firebase Service Account

```bash
# Run this command (requires gcloud CLI):
bash scripts/create_firebase_service_account.sh simplysoph-66c78 github-actions-deploy
```

**Expected output:** `github-actions-key.json` file created

---

### ☐ GitHub Secret Configuration

1. Copy the contents of `github-actions-key.json`
2. Go to: https://github.com/YOUR_USERNAME/SimplySoph-SimplyStyles/settings/secrets/actions
3. Click **New repository secret**
4. Name: `FIREBASE_SERVICE_ACCOUNT`
5. Value: Paste the entire JSON content
6. Click **Add secret**

---

### ☐ Verify Firebase Project

```bash
firebase projects:list
# Should show: simplysoph-66c78

firebase use
# Should show: Active Project: simplysoph-66c78 (simplysoph-66c78)
```

---

## Testing Before Push

### ☐ Run Tests Locally

```bash
flutter test --coverage
```

**Expected:** All tests pass ✅

### ☐ Run Code Analysis

```bash
flutter analyze
```

**Expected:** No issues found ✅

### ☐ Build Web Locally

```bash
flutter build web --release
```

**Expected:** Build completes successfully ✅

### ☐ Build Android Locally (Optional)

```bash
flutter build apk --release
```

**Expected:** APK created at `build/app/outputs/flutter-apk/app-release.apk` ✅

---

## Deployment

### ☐ Push to GitHub

```bash
git add .
git commit -m "feat: enable CI/CD pipeline"
git push origin main
```

### ☐ Monitor GitHub Actions

1. Go to: https://github.com/YOUR_USERNAME/SimplySoph-SimplyStyles/actions
2. Watch the workflow run
3. Verify all jobs complete successfully:
   - ✅ test
   - ✅ build-web
   - ✅ build-android
   - ✅ deploy

---

## Post-Deployment Verification

### ☐ Check Firebase Hosting

- Console: https://console.firebase.google.com/project/simplysoph-66c78/hosting
- Live URL: https://simplysoph-66c78.web.app

### ☐ Test Live Application

- [ ] App loads correctly
- [ ] Authentication works
- [ ] Firebase connection active
- [ ] No console errors

### ☐ Download Build Artifacts (Optional)

1. Go to completed workflow run
2. Scroll to **Artifacts** section
3. Download `web-build` or `android-apk`

---

## Troubleshooting

### ❌ Service Account Error

```bash
# Verify service account exists
gcloud iam service-accounts list --project=simplysoph-66c78
```

### ❌ Permission Denied

```bash
# Check IAM permissions
gcloud projects get-iam-policy simplysoph-66c78 \
  --flatten="bindings[].members" \
  --filter="bindings.members:github-actions-deploy"
```

### ❌ Tests Failing

```bash
# Run tests with verbose output
flutter test --reporter expanded
```

### ❌ Build Failing

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

---

## Quick Commands Reference

| Task                 | Command                                      |
| -------------------- | -------------------------------------------- |
| Login to gcloud      | `gcloud auth login`                          |
| Set project          | `gcloud config set project simplysoph-66c78` |
| Login to Firebase    | `firebase login`                             |
| Use Firebase project | `firebase use simplysoph-66c78`              |
| Run tests            | `flutter test`                               |
| Analyze code         | `flutter analyze`                            |
| Build web            | `flutter build web --release`                |
| Build Android        | `flutter build apk --release`                |
| View workflows       | Visit Actions tab on GitHub                  |

---

## Success Criteria ✅

- [ ] Service account created
- [ ] GitHub secret configured
- [ ] All tests pass in CI
- [ ] Web build succeeds
- [ ] Android build succeeds
- [ ] Deployment to Firebase completes
- [ ] Live app is accessible
- [ ] No errors in browser console

---

**Status:** Ready to deploy! 🎉

---

# Deploy Now Guide

## 🎯 Quick Deploy (Easiest Method)

### For Mac/Linux Users:

```bash
./scripts/deploy.sh
```

### For Windows Users:

```bash
scripts\deploy.bat
```

That's it! The script will automatically build and deploy your app. ✨

---

## 📋 Manual Deployment (Step-by-Step)

If you prefer to do it manually or the script doesn't work, follow these steps:

### Step 1: Install Prerequisites

Make sure you have Flutter and Firebase CLI installed:

```bash
# Check if Flutter is installed
flutter --version

# Install Firebase CLI (if not installed)
npm install -g firebase-tools
```

### Step 2: Login to Firebase

```bash
firebase login
```

This will open your browser. Log in with the Google account that owns the `simplysoph-66c78` project.

### Step 3: Enable Web Support

```bash
flutter config --enable-web
```

### Step 4: Get Dependencies

```bash
flutter pub get
```

### Step 5: Build the Web App

```bash
flutter build web --release
```

This creates optimized files in the `build/web` folder. It might take a few minutes.

### Step 6: Deploy to Firebase

```bash
firebase deploy --only hosting
```

Wait for the deployment to complete. You'll see a progress bar in your terminal.

### Step 7: Visit Your Live App! 🎉

Once deployment is complete, your app will be live at:

**https://simplysoph-66c78.web.app**

You can also access it at:

**https://simplysoph-66c78.firebaseapp.com**

---

## 🔧 What I've Already Configured

I've set up all the necessary configuration files for you:

| File                     | Purpose                                 |
| ------------------------ | --------------------------------------- |
| `firebase.json`          | Firebase hosting configuration          |
| `.firebaserc`            | Your project ID (`simplysoph-66c78`)    |
| `firestore.rules`        | Database security rules                 |
| `storage.rules`          | File storage security rules             |
| `firestore.indexes.json` | Database query optimization             |
| `scripts/deploy.sh`      | Automated deployment script (Mac/Linux) |
| `scripts/deploy.bat`     | Automated deployment script (Windows)   |

---

## 🎨 Updating Your Live App

Whenever you make changes to your app:

1. **Make your code changes** in VS Code
2. **Run the deploy script** again:
   ```bash
   ./scripts/deploy.sh   # Mac/Linux
   scripts\deploy.bat    # Windows
   ```

Or manually:

```bash
flutter build web --release
firebase deploy --only hosting
```

Your changes will be live in about 1-2 minutes!

---

## 🔒 Security Rules Deployed

I've also prepared security rules for your database and storage:

### Firestore Rules

- Users can only read/write their own data
- Wardrobe items are private to each user
- Style personas are private to each user
- Trends are read-only (managed by Cloud Functions)

### Storage Rules

- Users can only upload to their own folders
- Maximum file size: 10MB
- Only image files are allowed

These rules will be deployed when you run:

```bash
firebase deploy
```

---

## 🌐 Sharing Your App

Once deployed, you can share your app with anyone! Just send them the link:

**https://simplysoph-66c78.web.app**

The app will work on:

- ✅ Desktop browsers (Chrome, Firefox, Safari, Edge)
- ✅ Mobile browsers (iOS Safari, Android Chrome)
- ✅ Tablets

---

## 🐛 Troubleshooting

### "Firebase command not found"

Install Firebase CLI:

```bash
npm install -g firebase-tools
```

### "Flutter command not found"

Install Flutter: https://docs.flutter.dev/get-started/install

### "Permission denied" on scripts/deploy.sh

Make it executable:

```bash
chmod +x scripts/deploy.sh
```

### "Build failed"

Make sure all dependencies are installed:

```bash
flutter pub get
flutter doctor
```

### "Deployment failed"

Make sure you're logged into the correct Firebase account:

```bash
firebase logout
firebase login
```

---

## 📱 What About Mobile Apps?

This deployment creates a **web app** that works on all devices through the browser. If you want native iOS and Android apps later, you'll need to:

1. Build for Android: `flutter build apk`
2. Build for iOS: `flutter build ios` (requires a Mac)
3. Submit to app stores

But for now, the web app is the fastest way to get your app in people's hands!

---

## 🎉 Ready to Deploy?

Run this command and watch the magic happen:

```bash
./scripts/deploy.sh
```

Your app will be live in just a few minutes! 🚀✨

---

**Questions?** Check the `FIREBASE_HOSTING_GUIDE.md` for more details, or refer to the [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting).

---

# Storage Rules Deployment

## The Problem

Storage rules have hardcoded bucket name instead of wildcard, causing authorization errors.

## The Fix

Updated `storage.rules` line 3 from:

```
match /b/simplysoph-66c78.firebasestorage.app/o {
```

to:

```
match /b/{bucket}/o {
```

## Deploy Instructions

### Option 1: Firebase Console (Recommended - Immediate)

1. Go to: https://console.firebase.google.com/project/simplysoph-66c78/storage/rules
2. Replace all rules with:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId
                   && request.resource.size < 10 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

3. Click "Publish"
4. Test upload immediately

### Option 2: GitHub Actions (Automatic on next push)

The rules will auto-deploy on next commit to main branch via CI/CD.

### Option 3: Firebase CLI (If installed)

```bash
firebase deploy --only storage
```

## Verify Fix

After deployment:

1. Log into app
2. Go to My Closet
3. Click + to add item
4. Select an image
5. Upload should succeed without authorization error

---

# Quick Deploy Guide

## One-Time Setup (5 minutes)

### 1. Create Service Account

```bash
# Windows
scripts\setup-cicd.bat

# Mac/Linux
bash scripts/create_firebase_service_account.sh simplysoph-66c78 github-actions-deploy
```

### 2. Add GitHub Secret

1. Copy contents of `github-actions-key.json`
2. Go to: **GitHub repo → Settings → Secrets → Actions**
3. New secret: `FIREBASE_SERVICE_ACCOUNT`
4. Paste JSON → Save

### 3. Push Code

```bash
git add .
git commit -m "feat: enable CI/CD"
git push origin main
```

**Done!** 🎉

---

## Daily Workflow

### Deploy to Production

```bash
git add .
git commit -m "your message"
git push origin main
```

→ Auto-deploys to https://simplysoph-66c78.web.app

### Test Before Merge

```bash
git checkout -b feature/my-feature
git add .
git commit -m "feat: new feature"
git push origin feature/my-feature
```

→ Create PR → Get preview URL in PR comments

---

## Quick Commands

| Task             | Command                       |
| ---------------- | ----------------------------- |
| Run tests        | `flutter test`                |
| Check code       | `flutter analyze`             |
| Build web        | `flutter build web --release` |
| Build Android    | `flutter build apk --release` |
| View deployments | Visit GitHub Actions tab      |

---

## URLs

- **Live App**: https://simplysoph-66c78.web.app
- **Firebase Console**: https://console.firebase.google.com/project/simplysoph-66c78
- **GitHub Actions**: https://github.com/YOUR_USERNAME/SimplySoph-SimplyStyles/actions

---

## Troubleshooting

**Tests fail?**

```bash
flutter test --reporter expanded
```

**Build fails?**

```bash
flutter clean && flutter pub get
```

**Deployment fails?**

- Check GitHub secret is set
- Verify service account exists: `gcloud iam service-accounts list --project=simplysoph-66c78`

---

**Need help?** See [CI_CD_SETUP.md](CI_CD_SETUP.md) for detailed guide.

---

# Pre-Deployment Checklist - Upload Fix

## Before Deployment

### Code Review

- [x] Token refresh added to ImageService
- [x] Error handling improved in AddItemScreen
- [x] No hardcoded values or credentials
- [x] Code follows existing patterns
- [x] Comments added where necessary

### Testing

- [x] Upload validation tests passing (9/9)
- [x] No regressions in existing tests
- [x] Manual testing completed locally
- [x] Error scenarios tested
- [x] Edge cases considered

### Security

- [x] Storage rules validated
- [x] User isolation maintained
- [x] File size limits enforced
- [x] Content type validation active
- [x] Authentication required

### Documentation

- [x] UPLOAD_FIX_COMPLETE.md created
- [x] UPLOAD_FIX_VERIFICATION.md created
- [x] INVESTOR_READY_SUMMARY.md created
- [x] Code comments added
- [x] Deployment script created

## Deployment Steps

### 1. Pre-Deployment (5 minutes)

```bash
# Run tests
flutter test test/upload_validation_test.dart

# Build web app
flutter build web
```

**Expected Result**: All tests pass, build succeeds

### 2. Deploy (5 minutes)

```bash
# Option A: Use automated script
scripts\deploy-upload-fix.bat

# Option B: Manual deployment
firebase deploy --only hosting
```

**Expected Result**: Deployment succeeds, no errors

### 3. Immediate Verification (5 minutes)

- [ ] Visit https://simplysoph-66c78.web.app
- [ ] Log in with test account
- [ ] Navigate to My Closet
- [ ] Upload a test image
- [ ] Verify item appears in closet
- [ ] Check Firebase Console > Storage
- [ ] Verify file uploaded to correct path

### 4. Extended Verification (30 minutes)

- [ ] Test with multiple image sizes
- [ ] Test with different image formats (jpg, png)
- [ ] Test error handling (file too large)
- [ ] Test on different browsers (Chrome, Firefox, Safari)
- [ ] Test on mobile device
- [ ] Verify thumbnail generation
- [ ] Check Firebase Console logs for errors

## Post-Deployment Monitoring

### First Hour

- [ ] Monitor Firebase Console > Storage > Usage
- [ ] Check Firebase Console > Authentication > Users
- [ ] Review Firebase Console > Hosting > Usage
- [ ] Watch for error spikes in logs
- [ ] Test upload from different accounts

### First 24 Hours

- [ ] Check upload success rate
- [ ] Monitor storage quota usage
- [ ] Review user feedback (if any)
- [ ] Check for any error patterns
- [ ] Verify thumbnail generation working

### First Week

- [ ] Analyze upload metrics
- [ ] Gather user feedback
- [ ] Identify any edge cases
- [ ] Plan optimizations if needed

## Rollback Plan (If Needed)

### If Upload Fails After Deployment

1. Check Firebase Console > Storage > Rules
2. Verify rules match `storage.rules` file
3. Check Firebase Console > Authentication
4. Review browser console for errors
5. Check network tab for failed requests

### If Critical Issue Found

```bash
# Rollback to previous version
firebase hosting:rollback

# Or redeploy previous version
git checkout <previous-commit>
flutter build web
firebase deploy --only hosting
```

## Success Criteria

### Must Have (Before Investor Demo)

- [x] Upload succeeds for authenticated users
- [x] Items appear in closet immediately
- [x] Thumbnails generate correctly
- [x] Error messages are user-friendly
- [x] No security vulnerabilities
- [x] Performance is acceptable (< 10s upload)

### Nice to Have (Can be added later)

- [ ] Progress bar during upload
- [ ] Image preview before upload
- [ ] Bulk upload support
- [ ] Drag-and-drop upload
- [ ] Camera integration (mobile)

## Contact Information

### Firebase Console

- Project: simplysoph-66c78
- Console: https://console.firebase.google.com/project/simplysoph-66c78

### Live App

- URL: https://simplysoph-66c78.web.app
- Status: https://simplysoph-66c78.web.app/__/firebase/init.json

### Documentation

- Technical: UPLOAD_FIX_COMPLETE.md
- Verification: UPLOAD_FIX_VERIFICATION.md
- Investor: INVESTOR_READY_SUMMARY.md

## Final Checks

Before notifying investment team:

- [ ] Deployment successful
- [ ] Upload tested and working
- [ ] No errors in Firebase Console
- [ ] Documentation complete
- [ ] Demo script prepared
- [ ] Backup plan ready

## Sign-Off

**Developer**: ******\_\_\_****** Date: ******\_\_\_******

**QA/Tester**: ******\_\_\_****** Date: ******\_\_\_******

**Deployment**: ******\_\_\_****** Date: ******\_\_\_******

---

## Ready to Deploy?

If all checkboxes above are marked, you're ready to:

1. Run `scripts\deploy-upload-fix.bat`
2. Verify upload functionality
3. Notify investment team
4. Schedule demo

**Good luck with your investor presentation! 🚀**
