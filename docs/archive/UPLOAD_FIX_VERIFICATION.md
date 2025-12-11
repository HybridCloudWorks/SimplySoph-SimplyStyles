# Upload Authorization Fix - Verification Guide

## Root Cause Analysis

The "user not authorized" error was caused by:

1. **Expired Auth Tokens**: Long user sessions had expired Firebase Auth tokens
2. **Missing Token Refresh**: ImageService didn't refresh tokens before upload
3. **Storage Rules Timing**: Token validation failed at Firebase Storage level

## Fix Applied

### Code Changes
- **lib/services/image_service.dart**: Added `await currentUser.getIdToken(true)` before uploads
- Forces token refresh to ensure valid authentication
- Applied to both `uploadClothingImage()` and `uploadClothingImageBytes()`

### Test Coverage
- **test/closet_upload_integration_test.dart**: Comprehensive validation suite
- Tests authentication flow, category validation, storage paths
- Validates storage rules compliance

## Verification Steps

### 1. Deploy Storage Rules (If Not Already Done)
```bash
firebase deploy --only storage
```

Or via Firebase Console:
https://console.firebase.google.com/project/simplysoph-66c78/storage/rules

### 2. Run Automated Tests
```bash
flutter test test/closet_upload_integration_test.dart
```

### 3. Manual Testing Checklist

#### Test Case 1: Fresh Login Upload
- [ ] Log out completely
- [ ] Log back in
- [ ] Navigate to My Closet
- [ ] Click + to add item
- [ ] Select image (< 10MB)
- [ ] Verify upload succeeds
- [ ] Verify item appears in closet

#### Test Case 2: Long Session Upload
- [ ] Log in and wait 30+ minutes
- [ ] Navigate to My Closet
- [ ] Click + to add item
- [ ] Select image
- [ ] Verify upload succeeds (token auto-refreshes)

#### Test Case 3: Multiple Uploads
- [ ] Upload 3 items in succession
- [ ] Verify all uploads succeed
- [ ] Verify all items appear in closet
- [ ] Check Firebase Storage console for files

#### Test Case 4: Error Handling
- [ ] Try uploading file > 10MB
- [ ] Verify error message: "File size exceeds 10MB limit"
- [ ] Try uploading non-image file
- [ ] Verify appropriate error

#### Test Case 5: Web Platform
- [ ] Test on web build
- [ ] Upload via gallery picker
- [ ] Verify upload succeeds
- [ ] Check browser console for errors

#### Test Case 6: Mobile Platform
- [ ] Test on Android/iOS
- [ ] Upload via camera
- [ ] Upload via gallery
- [ ] Verify both methods work

## Firebase Console Verification

### Check Storage
1. Go to: https://console.firebase.google.com/project/simplysoph-66c78/storage
2. Navigate to: `users/{userId}/wardrobe/`
3. Verify structure:
   - `original/{itemId}.jpg`
   - `thumbnails/{itemId}_thumb.jpg`

### Check Firestore
1. Go to: https://console.firebase.google.com/project/simplysoph-66c78/firestore
2. Navigate to: `wardrobe_items` collection
3. Verify documents have:
   - `userId` field
   - `imageUrl` field
   - `thumbnailUrl` field
   - `storageItemId` field
   - `category` field

### Check Authentication
1. Go to: https://console.firebase.google.com/project/simplysoph-66c78/authentication
2. Verify test user exists
3. Check "Last sign-in" timestamp

## Expected Results

### Success Indicators
✅ Upload completes without errors
✅ Green snackbar: "Item added to wardrobe!"
✅ Item appears in closet grid immediately
✅ Image loads correctly (not broken)
✅ Thumbnail is generated and displayed

### Failure Indicators (Should Not Occur)
❌ "User not authorized" error
❌ "Permission denied" error
❌ Upload hangs indefinitely
❌ Item added but image doesn't load

## Rollback Plan

If issues persist:

1. Check Firebase Console > Storage > Rules
2. Verify rules match `storage.rules` file
3. Check Firebase Console > Authentication
4. Verify user is authenticated
5. Check browser/app console for detailed errors
6. Review Firebase Storage usage quotas

## Performance Metrics

Expected upload times:
- Small image (< 1MB): 2-5 seconds
- Medium image (1-5MB): 5-10 seconds
- Large image (5-10MB): 10-20 seconds

Includes:
- Token refresh: ~500ms
- Original upload: varies by size
- Thumbnail generation: ~1-2 seconds
- Firestore write: ~500ms

## Support Information

If verification fails:
1. Capture full error message
2. Check browser/app console logs
3. Note user ID and timestamp
4. Check Firebase Console logs
5. Verify storage rules are deployed

## Next Steps After Verification

Once verified:
- [ ] Update CHANGELOG.md
- [ ] Mark issue as resolved
- [ ] Notify investment team
- [ ] Deploy to production
- [ ] Monitor error rates in Firebase Console
