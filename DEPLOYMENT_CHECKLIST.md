# 🚀 Deployment Checklist

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

| Task | Command |
|------|---------|
| Login to gcloud | `gcloud auth login` |
| Set project | `gcloud config set project simplysoph-66c78` |
| Login to Firebase | `firebase login` |
| Use Firebase project | `firebase use simplysoph-66c78` |
| Run tests | `flutter test` |
| Analyze code | `flutter analyze` |
| Build web | `flutter build web --release` |
| Build Android | `flutter build apk --release` |
| View workflows | Visit Actions tab on GitHub |

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
