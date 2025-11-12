# Firebase Extensions Documentation

## Overview
Firebase Extensions are pre-built solutions that automate common tasks. This document covers extensions for SimplyStyles.

---

## ✅ Installed Extensions

### 1. Delete User Data ✅ INSTALLED
**Purpose**: GDPR compliance - automatically delete user data when account is deleted  
**Status**: ✅ Active  
**Cost**: Free

**Configuration**:
- **Firestore paths**: `users/{UID}, wardrobe_items, style_personas, recommendations`
- **Storage paths**: `users/{UID}`
- **Delete mode**: Recursive
- **Events**: Enabled

**What it does**:
- Listens for user account deletion
- Automatically deletes all Firestore documents
- Automatically deletes all Storage files
- Ensures GDPR/CCPA compliance

**No code changes needed** - works automatically when user deletes account.

---

### 2. Resize Images ✅ INSTALLED
**Purpose**: Automatically generate thumbnails when images are uploaded  
**Status**: ✅ ACTIVE - Successfully installed  
**Cost**: Free tier: 2000 operations/month

**Installation Settings**:

**Basic Configuration**:
- **Cloud Functions location**: Iowa (us-central1)
- **Cloud Storage bucket**: `simplysoph-66c78.firebasestorage.app` (Default bucket)
- **Sizes of resized images**: `300x300`
- **Deletion of original file**: `Don't delete`
- **Make resized images public**: `No`
- **Cloud Storage path for resized images**: `thumbnails`
- **Paths that contain images**: Leave empty (processes all)
- **List of absolute paths not included**: Leave empty
- **Cloud Storage path for failed images**: `failed`
- **Cache-Control header**: `max-age=86400`
- **Convert image to preferred types**: `original`
- **Output options**: Leave empty
- **Sharp constructor options**: Leave empty
- **GIF and WEBP animated option**: `Yes`

**Function Configuration**:
- **Cloud Function memory**: `2 GB`
- **Backfill existing images**: Leave empty
- **Backfill batch size**: `3`
- **Assign new access token**: `Yes`
- **Content filter level**: `Off (No filtering)`
- **Enable events**: ✅ Checked

**Advanced Parameters** (all default/empty):
- Function timeout, VPC, instances, ingress, labels, KMS, Docker: Leave empty/default

**What it does**:
- Watches for new uploads to `wardrobe/original/`
- Automatically creates 300x300 thumbnail
- Saves to `wardrobe/thumbnails/` folder
- Maintains aspect ratio

**Code changes needed**:
```dart
// OLD: Manual thumbnail generation
final thumbnailUrl = await _createAndUploadThumbnail(...);

// NEW: Use auto-generated thumbnail
final thumbnailUrl = originalUrl.replaceAll('/original/', '/thumbnails/')
    .replaceAll('.jpg', '_300x300.jpg');
```

---

## 📋 Recommended Extensions to Install

### 3. Trigger Email from Firestore
**Purpose**: Send transactional emails  
**Status**: Not installed  
**Cost**: Free tier: 200 emails/day

**Use cases**:
- Welcome email on signup
- Password reset
- Onboarding completion
- Weekly style tips
- New trend notifications

**Configuration**:
- **SMTP**: Use SendGrid free tier or Gmail
- **Collection**: `mail`
- **From address**: `noreply@simplysoph.com`

**How to use**:
```dart
// Send welcome email
await FirebaseFirestore.instance.collection('mail').add({
  'to': user.email,
  'message': {
    'subject': 'Welcome to SimplyStyles!',
    'text': 'Thanks for joining...',
    'html': '<h1>Welcome!</h1>...',
  },
});
```

**Install**: https://extensions.dev/extensions/firebase/firestore-send-email

---

### 4. Firestore Counter
**Purpose**: Efficiently track counts without expensive queries  
**Status**: Not installed  
**Cost**: Free

**Use cases**:
- Track total wardrobe items per user
- Track total personas per user
- Track app-wide statistics
- Avoid expensive `count()` queries

**Configuration**:
- **Collection**: `_counters`
- **Shard count**: 3

**How to use**:
```dart
// Increment counter when adding item
await FirebaseFirestore.instance
  .collection('_counters')
  .doc('user_${userId}_items')
  .set({'count': FieldValue.increment(1)}, SetOptions(merge: true));

// Read count
final doc = await FirebaseFirestore.instance
  .collection('_counters')
  .doc('user_${userId}_items')
  .get();
final itemCount = doc.data()?['count'] ?? 0;
```

**Install**: https://extensions.dev/extensions/firebase/firestore-counter

---

## 🔮 Future Extensions (Install When Needed)

### 5. Stream Collections to BigQuery ✅ INSTALLING
**Purpose**: Real-time analytics and data warehouse  
**Status**: 🚀 Installing 4 instances (one per collection)  
**Cost**: BigQuery free tier: 10GB storage, 1TB queries/month

**Configuration Template** (use for all 4 collections):

**Page 1 - Basic Settings**:
- Dataset location: `Multi-region (United States)`
- Collection path: `[COLLECTION_NAME]` (change per collection)
- Enable Wildcard Column: `No`
- Dataset ID: `simplysoph_analytics`
- Table ID: `[COLLECTION_NAME]` (same as collection path)
- Time Partitioning option: `DAY`
- Time Partitioning column name: `timestamp`
- Firestore field for Time Partitioning: `createdAt`
- Time Partitioning schema type: `TIMESTAMP`
- Table clustering: See below per collection
- Maximum synced documents: `100`
- View Type: `View`

**Page 2 - Advanced Settings**:
- Maximum Staleness Duration: `INTERVAL "8:0:0" HOUR TO SECOND`
- Refresh Interval: `60`
- Backup Collection Name: Leave empty
- Transform function URL: Leave empty
- Use new query syntax: `No`
- Exclude old data payloads: `No`
- Cloud KMS key name: Leave empty
- Maximum enqueue attempts: `3`
- Log level: `Info`
- Events: Check **onError** only

**Collection-Specific Settings**:

**Extension 1: wardrobe_items**
- Collection path: `wardrobe_items`
- Table ID: `wardrobe_items`
- Table clustering: `userId,category`

**Extension 2: style_personas**
- Collection path: `style_personas`
- Table ID: `style_personas`
- Table clustering: `userId`

**Extension 3: users**
- Collection path: `users`
- Table ID: `users`
- Table clustering: Leave empty

**Extension 4: recommendations**
- Collection path: `recommendations`
- Table ID: `recommendations`
- Table clustering: `userId`

**Use cases**:
- User behavior analysis
- Popular styles/colors/brands tracking
- Conversion funnel analysis
- A/B testing results
- Trend prediction
- Business intelligence dashboards

**Recommended Collections to Export**:
1. `wardrobe_items` - Track what users add
2. `style_personas` - Track generated personas
3. `users` - Track user demographics
4. `recommendations` - Track AI recommendations

**Configuration**:
- **Collection path**: `wardrobe_items` (install separately for each collection)
- **Dataset ID**: `simplysoph_analytics`
- **Table ID**: `wardrobe_items`
- **Backup collection**: `wardrobe_items_backup`

**Install**: https://extensions.dev/extensions/firebase/firestore-bigquery-export

**After Installation**:
```sql
-- Query most popular clothing categories
SELECT category, COUNT(*) as count
FROM `simplysoph-66c78.simplysoph_analytics.wardrobe_items`
GROUP BY category
ORDER BY count DESC;

-- Query most popular colors
SELECT color, COUNT(*) as count
FROM `simplysoph-66c78.simplysoph_analytics.wardrobe_items`
GROUP BY color
ORDER BY count DESC;
```

---

### 6. Translate Text in Firestore
**Purpose**: Multi-language support  
**When**: Expanding internationally  
**Cost**: Google Translate API pricing

**Use cases**:
- Translate UI text
- Translate style descriptions
- Multi-language support

**Install**: https://extensions.dev/extensions/firebase/firestore-translate-text

---

### 7. Shorten URLs with Bitly
**Purpose**: Create shareable links  
**When**: Adding social sharing  
**Cost**: Bitly free tier

**Use cases**:
- Share outfit combinations
- Share style personas
- Referral links

**Install**: https://extensions.dev/extensions/firebase/firestore-shorten-urls-bitly

---



---

## 🤖 AI/ML Integration

### Current Implementation: Gemini API ✅ RECOMMENDED

**Why Gemini (not Vertex AI Cortex)**:
- ✅ **Simpler**: Direct API calls, no complex setup
- ✅ **Cheaper**: Pay-per-use, no minimum commitment
- ✅ **Faster**: Lower latency for image analysis
- ✅ **Better for fashion**: Gemini Vision excels at clothing/style analysis
- ✅ **Already integrated**: Your Cloud Functions use Gemini

**Your Current AI Stack**:
- **Gemini 1.5 Flash** - Image analysis (category, color, style, brand)
- **Cloud Functions** - Custom AI logic
- **Firestore** - Store AI results

**Already implemented in** `functions/index.js`:
- `vortex_analyzeItem` - Analyze clothing images with Gemini
- `vortex_generatePersonas` - Generate style personas
- `vortex_calculateFit` - Calculate item fit score

**Cost Comparison**:
- **Gemini API**: $0.00025 per image (1000 images = $0.25)
- **Vertex AI**: $0.0025 per image + infrastructure (1000 images = $2.50+)

### When to Use Vertex AI (Future)

**Use Vertex AI only if**:
- Need custom model training on your data
- Need batch processing of 10K+ images
- Need AutoML for specialized fashion detection
- Need model versioning and A/B testing

**Vertex AI Extensions** (don't install yet):
- **Vertex AI Image Captioning**: Auto-generate descriptions
- **Vertex AI Vision**: Custom object detection
- **AutoML Vision**: Train custom fashion models

### BigQuery + Gemini Integration (Future)

**BigQuery ML with Gemini** (after installing BigQuery export):
```sql
-- Analyze trends using Gemini in BigQuery
SELECT
  category,
  ML.GENERATE_TEXT(
    MODEL `simplysoph-66c78.simplysoph_analytics.gemini_model`,
    (SELECT CONCAT('Analyze fashion trends for: ', category) as prompt)
  ) as trend_analysis
FROM `simplysoph-66c78.simplysoph_analytics.wardrobe_items`
GROUP BY category;
```

**Current Status**: 🚀 CONFIGURING NOW
- Enabling Vertex AI API
- Updating Cloud Functions to use Vertex AI Gemini endpoint
- Keeping Gemini model (not switching to Cortex)
- See BIGQUERY_VERTEX_SETUP.md for complete setup

**Recommendation**: Using Gemini via Vertex AI (production-ready, better monitoring).

---

## Installation Priority

### ✅ Installed (Complete)
1. ✅ Delete User Data - Active
2. ✅ Resize Images - Active (successfully reinstalled)

### 🚀 Installing NOW
3. 🔄 **BigQuery Export** - Installing 4 extensions:
   - ⏳ wardrobe_items
   - ⏳ style_personas  
   - ⏳ users
   - ⏳ recommendations
4. ⏳ **Vertex AI** - Gemini integration via Vertex AI endpoint

### 🎯 Install Next (High Priority)
5. **Trigger Email** - Better user experience
6. **Firestore Counter** - Performance optimization

### ⏳ Install Later (When Needed)
5. Export to BigQuery - When you need analytics
6. Translate Text - When going international
7. Shorten URLs - When adding social features

---

## Cost Estimates

### Current (MVP - 100 users)
- Delete User Data: Free
- Resize Images: Free (< 2000 ops/month)
- **Total**: $0/month

### With Email (100 users)
- Delete User Data: Free
- Resize Images: Free
- Trigger Email: Free (< 200 emails/day)
- **Total**: $0/month

### At Scale (10K users)
- Delete User Data: Free
- Resize Images: ~$5/month
- Trigger Email: ~$20/month (SendGrid)
- Firestore Counter: Free
- **Total**: ~$25/month

### At 100K users
- Delete User Data: Free
- Resize Images: ~$50/month
- Trigger Email: ~$200/month
- Firestore Counter: Free
- BigQuery: ~$100/month
- **Total**: ~$350/month

---

## Code Changes After Installing Extensions

### Update ImageService (After Resize Images)

**Remove manual thumbnail generation**:
```dart
// DELETE THIS METHOD:
Future<String> _createAndUploadThumbnail(...) {
  // Remove entire method
}
```

**Update uploadClothingImageBytes**:
```dart
Future<Map<String, String>> uploadClothingImageBytes({
  required String userId,
  required Uint8List imageBytes,
}) async {
  final itemId = _uuid.v4();

  // Upload original only
  final originalRef = _storage.ref('users/$userId/wardrobe/original/$itemId.jpg');
  await originalRef.putData(imageBytes);
  final originalUrl = await originalRef.getDownloadURL();

  // Extension will auto-generate thumbnail
  // Construct thumbnail URL based on extension naming
  final thumbnailUrl = originalUrl
      .replaceAll('/original/', '/thumbnails/')
      .replaceAll('.jpg', '_300x300.jpg');

  return {
    'original': originalUrl,
    'thumbnail': thumbnailUrl,
    'itemId': itemId,
  };
}
```

### Add Email Notifications (After Trigger Email)

**Welcome email on signup**:
```dart
// In auth_service.dart after user creation
await FirebaseFirestore.instance.collection('mail').add({
  'to': email,
  'message': {
    'subject': 'Welcome to SimplyStyles! 👗',
    'html': '''
      <h1>Welcome ${displayName}!</h1>
      <p>We're excited to help you discover your style.</p>
      <p>Get started by adding your first clothing item!</p>
    ''',
  },
});
```

**Onboarding completion email**:
```dart
// In firestore_service.dart after saveAndCompleteOnboarding
await _firestore.collection('mail').add({
  'to': userEmail,
  'message': {
    'subject': 'Your Style Profile is Ready! ✨',
    'html': '''
      <h1>Profile Complete!</h1>
      <p>Your style preferences have been saved.</p>
      <p>Start building your digital wardrobe now!</p>
    ''',
  },
});
```

### Add Item Counters (After Firestore Counter)

**Increment on item add**:
```dart
// In wardrobe_service.dart after addItem
await FirebaseFirestore.instance
  .collection('_counters')
  .doc('user_${userId}_items')
  .set({'count': FieldValue.increment(1)}, SetOptions(merge: true));
```

**Decrement on item delete**:
```dart
// In wardrobe_service.dart after deleteItem
await FirebaseFirestore.instance
  .collection('_counters')
  .doc('user_${userId}_items')
  .set({'count': FieldValue.increment(-1)}, SetOptions(merge: true));
```

**Read count efficiently**:
```dart
// Replace expensive count query
Future<int> getItemCount(String userId) async {
  final doc = await FirebaseFirestore.instance
    .collection('_counters')
    .doc('user_${userId}_items')
    .get();
  return doc.data()?['count'] ?? 0;
}
```

---

## Monitoring Extensions

### View Extension Logs
1. Go to Firebase Console
2. Click **Extensions**
3. Click on extension name
4. Click **View in Cloud Functions**
5. Check logs for errors

### Monitor Costs
1. Go to Firebase Console
2. Click **Usage and billing**
3. View extension usage
4. Set budget alerts

### Check Extension Status
```bash
firebase ext:list
```

---

## Troubleshooting

### Resize Images Not Working
**Symptoms**: Thumbnails not generated

**Solutions**:
1. Check Storage rules allow extension to write
2. Verify path matches: `/users/{userId}/wardrobe/original`
3. Check extension logs in Functions tab
4. Ensure image is valid JPEG/PNG
5. Wait 30 seconds for processing

### Resize Images Gen1 Deployment Error
**Symptoms**: `RESOURCE_ERROR: Gen1 operation failed: Failed to configure trigger providers/cloud.storage/eventTypes/object.change`

**Root Cause**: Cloud Functions Gen1 has issues with new Storage bucket format or trigger configuration

**Solution - Reinstall via Console**:
1. Remove from firebase.json if present:
   ```json
   "extensions": {
     "storage-resize-images": "firebase/storage-resize-images@0.2.10"
   }
   ```
2. Firebase Console → Extensions → Install extension
3. Search "Resize Images"
4. Use configuration settings documented above
5. Key settings:
   - Bucket: `simplysoph-66c78.firebasestorage.app` (Default)
   - Size: `300x300`
   - Path: `thumbnails`
   - Memory: `2 GB`
   - Enable events: ✅

### Emails Not Sending
**Symptoms**: No emails received

**Solutions**:
1. Check spam folder
2. Verify SMTP credentials in extension config
3. Check extension logs
4. Ensure `mail` collection document structure is correct
5. Verify email address is valid

### Delete User Data Not Triggering
**Symptoms**: Data remains after user deletion

**Solutions**:
1. Verify user deletion is via Firebase Auth (not just Firestore)
2. Check extension logs
3. Ensure paths are configured correctly
4. Wait a few minutes for processing
5. Check "Enable events" is checked

### Firestore Counter Out of Sync
**Symptoms**: Count doesn't match actual items

**Solutions**:
1. Manually reset counter
2. Ensure increment/decrement on all operations
3. Check for failed transactions
4. Rebuild counter from actual data

---

## Uninstalling Extensions

**Warning**: Uninstalling removes the extension but keeps data.

```bash
# List installed extensions
firebase ext:list

# Uninstall an extension
firebase ext:uninstall EXTENSION_NAME
```

Or via Firebase Console:
1. Go to **Extensions**
2. Click extension
3. Click **Uninstall**

---

## Next Steps

1. ✅ Delete User Data - Installed
2. ✅ Resize Images - Installed
3. 📋 Install Trigger Email
4. 📋 Install Firestore Counter
5. 📋 Update ImageService code
6. 📋 Add email notifications
7. 📋 Add item counters
8. 📋 Test all extensions

---

## Resources

- **Extensions Hub**: https://extensions.dev/extensions
- **Firebase Extensions Docs**: https://firebase.google.com/docs/extensions
- **Extension Source Code**: https://github.com/firebase/extensions
- **Community Extensions**: https://extensions.dev/

---

**Last Updated**: 2024  
**Installed Extensions**: 2 (Delete User Data, Resize Images)  
**Status**: Ready to install Trigger Email and Firestore Counter
