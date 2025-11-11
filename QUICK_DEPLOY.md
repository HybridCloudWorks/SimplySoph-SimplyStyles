# 🚀 Quick Deploy Guide

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

| Task | Command |
|------|---------|
| Run tests | `flutter test` |
| Check code | `flutter analyze` |
| Build web | `flutter build web --release` |
| Build Android | `flutter build apk --release` |
| View deployments | Visit GitHub Actions tab |

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
