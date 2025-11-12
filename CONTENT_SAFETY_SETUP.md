# Content Safety & Moderation Setup

## Overview
SimplyStyles targets Gen Z users (ages 13-25), including teens. We MUST implement content safety filters for:
- Image uploads (nudity, violence detection)
- User comments/chat (profanity, toxicity filtering)
- AI-generated content (safe responses)

---

## Required Extensions for Teen Safety

### 1. Label Images with Cloud Vision AI ✅ INSTALL NOW
**Purpose**: Auto-detect inappropriate content in uploaded images  
**Priority**: CRITICAL - Must have before launch

**What it detects**:
- Adult content (nudity, sexual content)
- Violence (blood, weapons)
- Racy content (suggestive imagery)
- Medical content
- Spoof content

**Installation**:
1. Go to Firebase Console → Extensions
2. Search: **Label Images with Cloud Vision AI**
3. Click **Install**

**Configuration**:
- **Cloud Storage bucket path**: `users/{userId}/wardrobe`
- **Cloud Vision API features**: `SAFE_SEARCH_DETECTION,LABEL_DETECTION,OBJECT_LOCALIZATION`
- **Output Firestore collection**: `image_labels`
- **Backup collection**: Leave empty
- **Location**: us-central1

**After Installation**:
Images are automatically analyzed on upload. Check `image_labels` collection for results.

---

### 2. Detect Objects with Cloud Vision AI ✅ INSTALL NOW
**Purpose**: Verify uploaded images are actually clothing  
**Priority**: HIGH - Prevents spam/inappropriate uploads

**What it detects**:
- Objects in images (clothing, accessories, etc.)
- Verifies image is fashion-related
- Blocks non-clothing uploads

**Installation**:
1. Go to Firebase Console → Extensions
2. Search: **Detect Objects with Cloud Vision AI**
3. Click **Install**

**Configuration**:
- **Cloud Storage bucket path**: `users/{userId}/wardrobe`
- **Output Firestore collection**: `image_objects`
- **Location**: us-central1

---

### 3. Analyze Comment Toxicity ⚠️ INSTALL WHEN ADDING CHAT
**Purpose**: Filter profanity, hate speech, harassment in comments  
**Priority**: CRITICAL if adding chat/comments

**What it detects**:
- Profanity
- Insults
- Threats
- Identity-based hate
- Sexually explicit language

**Installation**:
1. Get Perspective API key: https://perspectiveapi.com/
2. Go to Firebase Console → Extensions
3. Search: **Analyze Comment Toxicity**
4. Click **Install**

**Configuration**:
- **Perspective API key**: Your API key
- **Firestore collection**: `comments`
- **Toxicity threshold**: `0.7` (0-1, lower = stricter)
- **Auto-moderate**: `Yes` (auto-hide toxic comments)

---

## Cloud Vision API Setup

### Enable Cloud Vision API
1. Go to https://console.cloud.google.com/apis/library/vision.googleapis.com?project=simplysoph-66c78
2. Click **Enable**

### Grant Permissions
1. Go to https://console.cloud.google.com/iam-admin/iam?project=simplysoph-66c78
2. Find: `simplysoph-66c78@appspot.gserviceaccount.com`
3. Add role: **Cloud Vision AI User**
4. Click **Save**

---

## Update Cloud Functions with Safety Checks

### Add Safe Search Detection to Image Upload

**functions/index.js** - Add new function:

```javascript
const vision = require('@google-cloud/vision');
const visionClient = new vision.ImageAnnotatorClient();

/**
 * Validates image safety before processing
 */
exports.validateImageSafety = functions.storage.object().onFinalize(async (object) => {
  const filePath = object.name;
  
  // Only check wardrobe images
  if (!filePath.includes('/wardrobe/')) {
    return null;
  }

  const bucket = admin.storage().bucket(object.bucket);
  const file = bucket.file(filePath);

  try {
    // Run safe search detection
    const [result] = await visionClient.safeSearchDetection(`gs://${object.bucket}/${filePath}`);
    const safeSearch = result.safeSearchAnnotation;

    // Check for inappropriate content
    const isUnsafe = 
      safeSearch.adult === 'VERY_LIKELY' ||
      safeSearch.adult === 'LIKELY' ||
      safeSearch.violence === 'VERY_LIKELY' ||
      safeSearch.racy === 'VERY_LIKELY';

    if (isUnsafe) {
      console.warn(`Unsafe image detected: ${filePath}`, safeSearch);
      
      // Delete the unsafe image
      await file.delete();
      
      // Log to Firestore for review
      await admin.firestore().collection('flagged_content').add({
        filePath,
        userId: filePath.split('/')[1],
        reason: 'unsafe_image',
        safeSearch,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      return null;
    }

    // Save safe search results
    await admin.firestore().collection('image_safety').add({
      filePath,
      safeSearch,
      safe: true,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    return null;
  } catch (error) {
    console.error('Error checking image safety:', error);
    return null;
  }
});
```

### Add Text Moderation for Comments (Future)

```javascript
const axios = require('axios');

/**
 * Moderates user comments for toxicity
 */
exports.moderateComment = functions.firestore
  .document('comments/{commentId}')
  .onCreate(async (snap, context) => {
    const comment = snap.data();
    const text = comment.text;

    if (!text) return null;

    try {
      // Call Perspective API
      const response = await axios.post(
        `https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=${PERSPECTIVE_API_KEY}`,
        {
          comment: { text },
          languages: ['en'],
          requestedAttributes: {
            TOXICITY: {},
            SEVERE_TOXICITY: {},
            PROFANITY: {},
            INSULT: {},
            THREAT: {},
          },
        }
      );

      const scores = response.data.attributeScores;
      const toxicityScore = scores.TOXICITY.summaryScore.value;
      const isToxic = toxicityScore > 0.7;

      // Update comment with moderation results
      await snap.ref.update({
        moderation: {
          toxicityScore,
          isToxic,
          autoHidden: isToxic,
          checkedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      });

      // Flag for manual review if toxic
      if (isToxic) {
        await admin.firestore().collection('flagged_content').add({
          type: 'comment',
          commentId: context.params.commentId,
          userId: comment.userId,
          text,
          toxicityScore,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      return null;
    } catch (error) {
      console.error('Error moderating comment:', error);
      return null;
    }
  });
```

---

## Firestore Security Rules for Safety

### Update firestore.rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Comments - only show non-toxic comments
    match /comments/{commentId} {
      allow read: if resource.data.moderation.autoHidden != true;
      allow create: if request.auth != null 
        && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null 
        && resource.data.userId == request.auth.uid;
    }
    
    // Flagged content - admin only
    match /flagged_content/{flagId} {
      allow read, write: if false; // Admin SDK only
    }
    
    // Image safety results - read only
    match /image_safety/{safetyId} {
      allow read: if request.auth != null;
      allow write: if false; // Cloud Functions only
    }
  }
}
```

---

## Flutter App Integration

### Check Image Safety Before Upload

**lib/services/image_service.dart**:

```dart
Future<bool> isImageSafe(Uint8List imageBytes) async {
  // Upload to temp location first
  final tempRef = _storage.ref('temp/${_uuid.v4()}.jpg');
  await tempRef.putData(imageBytes);
  
  // Wait for Cloud Function to process
  await Future.delayed(Duration(seconds: 3));
  
  // Check if image still exists (not deleted by safety check)
  try {
    await tempRef.getDownloadURL();
    // Image is safe, move to permanent location
    return true;
  } catch (e) {
    // Image was deleted (unsafe)
    return false;
  }
}
```

### Show Safety Warning to Users

```dart
if (!await isImageSafe(imageBytes)) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Image Not Allowed'),
      content: Text(
        'This image contains inappropriate content and cannot be uploaded. '
        'Please choose a different image of clothing items only.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
  return;
}
```

---

## Age Verification (Required for COPPA Compliance)

### Add Age Gate on Signup

**lib/screens/auth/signup_screen.dart**:

```dart
DateTime? _birthDate;

// Add date picker
TextButton(
  onPressed: () async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    setState(() => _birthDate = date);
  },
  child: Text(_birthDate == null 
    ? 'Select Birth Date' 
    : DateFormat('MM/dd/yyyy').format(_birthDate!)),
),

// Validate age
int getAge(DateTime birthDate) {
  final today = DateTime.now();
  int age = today.year - birthDate.year;
  if (today.month < birthDate.month || 
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  return age;
}

// Before signup
if (_birthDate == null) {
  // Show error
  return;
}

final age = getAge(_birthDate!);
if (age < 13) {
  // Show error - COPPA compliance
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Age Requirement'),
      content: Text('You must be at least 13 years old to use SimplyStyles.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
  return;
}

// Save age to user profile
await FirebaseFirestore.instance.collection('users').doc(userId).set({
  'birthDate': Timestamp.fromDate(_birthDate!),
  'age': age,
  'isMinor': age < 18,
}, SetOptions(merge: true));
```

---

## Monitoring & Reporting

### Admin Dashboard for Flagged Content

Create admin panel to review:
- Flagged images
- Toxic comments
- User reports

**Query flagged content**:
```dart
final flagged = await FirebaseFirestore.instance
  .collection('flagged_content')
  .orderBy('timestamp', descending: true)
  .limit(50)
  .get();
```

### Set Up Alerts

1. Go to Firebase Console → Alerts
2. Create alert for:
   - High number of flagged content (> 10/day)
   - Repeated violations by same user
   - Failed safety checks

---

## Cost Estimates

### Cloud Vision API
- **Free tier**: 1,000 images/month
- **Paid**: $1.50 per 1,000 images
- **Estimated**: $5-10/month for 5K images

### Perspective API (Comment Moderation)
- **Free tier**: 1 request/second
- **Paid**: Contact for pricing
- **Estimated**: Free for MVP

---

## Installation Checklist

### Immediate (Before Launch)
- [ ] Enable Cloud Vision API
- [ ] Install "Label Images with Cloud Vision AI" extension
- [ ] Install "Detect Objects with Cloud Vision AI" extension
- [ ] Add validateImageSafety Cloud Function
- [ ] Update Firestore security rules
- [ ] Add age verification to signup
- [ ] Test image upload with inappropriate content
- [ ] Test image upload with clothing items

### When Adding Chat/Comments
- [ ] Get Perspective API key
- [ ] Install "Analyze Comment Toxicity" extension
- [ ] Add moderateComment Cloud Function
- [ ] Add comment reporting feature
- [ ] Create admin moderation dashboard

### Ongoing
- [ ] Monitor flagged_content collection daily
- [ ] Review false positives/negatives
- [ ] Adjust toxicity thresholds as needed
- [ ] Update safety policies in Terms of Service

---

## Legal Requirements

### Terms of Service
- Minimum age: 13 years (COPPA)
- Prohibited content policy
- Consequences for violations
- Parental consent for users under 18

### Privacy Policy
- Data collection for minors
- Parental rights
- Content moderation practices
- Data retention policies

---

## Resources

- **Cloud Vision API**: https://cloud.google.com/vision/docs/detecting-safe-search
- **Perspective API**: https://perspectiveapi.com/
- **COPPA Compliance**: https://www.ftc.gov/business-guidance/resources/childrens-online-privacy-protection-rule-six-step-compliance-plan-your-business
- **Firebase Extensions**: https://extensions.dev/

---

**Status**: Ready to install extensions NOW  
**Priority**: CRITICAL for teen safety  
**Next Steps**: Install Label Images and Detect Objects extensions
