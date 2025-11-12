# Deploy Storage Rules Fix

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
