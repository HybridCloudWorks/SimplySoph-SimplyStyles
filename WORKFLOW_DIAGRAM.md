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
