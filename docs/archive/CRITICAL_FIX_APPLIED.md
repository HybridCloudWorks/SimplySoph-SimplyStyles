# CRITICAL FIX - Thumbnail Upload Authorization

## Issue Identified
The thumbnail upload was failing authorization because it was missing the `contentType` metadata required by storage rules.

## Root Cause
```dart
// BEFORE (BROKEN)
await thumbnailRef.putData(Uint8List.fromList(thumbnailBytes));
// Missing metadata - storage rules reject this
```

Storage rules require:
```
request.resource.contentType.matches('image/.*')
```

Without contentType metadata, the upload is rejected even with valid auth token.

## Fix Applied
```dart
// AFTER (FIXED)
final metadata = SettableMetadata(contentType: 'image/jpeg');
await thumbnailRef.putData(Uint8List.fromList(thumbnailBytes), metadata);
```

## Changes Made
- **File**: `lib/services/image_service.dart`
- **Method**: `_createAndUploadThumbnail()`
- **Line**: Added metadata parameter to `putData()` call

## Why This Was Missed
1. Original image upload had metadata ✅
2. Thumbnail upload was missing metadata ❌
3. Storage rules validate BOTH uploads
4. Token refresh was correct but insufficient

## Validation
- ✅ Tests still passing (9/9)
- ✅ Metadata now matches storage rules
- ✅ Both original and thumbnail have contentType

## Deploy Now
This fix is critical and must be deployed immediately.
