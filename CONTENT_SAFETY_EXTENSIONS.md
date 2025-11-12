# Content Safety Extensions - Installation Settings

## Installed Extensions

### 1. Label Images with Cloud Vision AI ✅ INSTALLED

**Purpose**: Detect inappropriate content and auto-label clothing items

**Settings**:
- **Cloud Functions location**: `Iowa (us-central1)`
- **Cloud Storage bucket**: `simplysoph-66c78.firebasestorage.app`
- **Paths that contain images**: `/users/{userId}/wardrobe`
- **List of absolute paths not included**: Leave empty
- **Collection path**: `imageLabels`
- **Amount of label information**: `Basic`
- **Advanced parameters**: Use defaults
- **Events**: Check **onError** only

**What it detects**:
- Safe search (adult content, violence, racy content)
- Object labels (shirt, dress, pants, etc.)
- Clothing categories

**Results stored in**: `imageLabels` Firestore collection

---

## Chatbot Extension - Build Chatbot with Gemini API ⬜ INSTALL NEXT

**Why Vertex AI (not Google AI Studio)**:
- ✅ Already enabled and configured
- ✅ Uses existing service account (no API key needed)
- ✅ Better for production (monitoring, quotas, security)
- ✅ Same Gemini models
- ✅ Integrated with your Cloud Functions

**Complete Settings**:

**Page 1 - Basic Configuration**:
- **Google AI API Key**: Leave empty (using Vertex AI)
- **Gemini model**: `gemini-1.5-flash`
- **Firestore Collection Path**: `chatSessions`
- **Prompt Field**: `prompt`
- **Response Field**: `response`
- **Order Field**: `createTime`
- **Cloud Functions location**: `Iowa (us-central1)`
- **Context (System Instruction)**:
```
You are a helpful fashion assistant for SimplyStyles, an app for Gen Z users. Help users with outfit suggestions, style advice, and wardrobe organization. Keep responses friendly, concise, and appropriate for teens (ages 13+). Never provide inappropriate content or personal advice outside of fashion.
```
- **Temperature**: `0.7`
- **Nucleus sampling probability**: Leave empty
- **Sampling strategy parameter**: Leave empty

**Page 2 - Advanced Configuration**:
- **Candidate count**: `1`
- **Max Output Tokens**: `1024`
- **Candidates field**: `candidates`
- **Enable per document overrides**: `No`
- **Enable Genkit Monitoring**: `No`

**Safety Thresholds (CRITICAL for teen protection)**:
- **Hate Speech Threshold**: `BLOCK_MEDIUM_AND_ABOVE`
- **Dangerous Content Threshold**: `BLOCK_MEDIUM_AND_ABOVE`
- **Harassment Content Threshold**: `BLOCK_MEDIUM_AND_ABOVE`
- **Sexual Content Threshold**: `BLOCK_MEDIUM_AND_ABOVE`

**Events**: Check **onError** only

---

## Next Extensions to Install

### 2. Detect Objects with Cloud Vision AI ⬜ INSTALL NEXT

**Purpose**: Verify uploaded images are actually clothing

**Settings**:
- **Cloud Functions location**: `Iowa (us-central1)`
- **Cloud Storage bucket**: `simplysoph-66c78.firebasestorage.app`
- **Paths that contain images**: `/users/{userId}/wardrobe`
- **Collection path**: `imageObjects`
- **Confidence threshold**: `0.7`

---

### 3. Analyze Comment Toxicity ⬜ INSTALL WHEN ADDING CHAT

**Purpose**: Filter profanity and toxic comments

**Prerequisites**:
- Get Perspective API key from https://perspectiveapi.com/

**Settings**:
- **Perspective API key**: Your API key
- **Firestore collection**: `comments`
- **Toxicity threshold**: `0.7`
- **Auto-moderate**: `Yes`

---

## Cost Summary

**Label Images**:
- Free tier: 1,000 images/month
- Paid: $1.50 per 1,000 images
- Estimated: $5-10/month

**Chatbot (Vertex AI)**:
- Gemini 1.5 Flash: $0.00025 per 1K characters
- Estimated: $5-15/month for 10K messages

**Detect Objects**:
- Same as Label Images (included in Vision API quota)

**Perspective API**:
- Free: 1 request/second
- Estimated: $0/month

**Total**: $10-25/month for MVP

---

## Installation Checklist

### ✅ Installed
- [x] Delete User Data (GDPR compliance)
- [x] Resize Images (auto-thumbnails)
- [x] Label Images with Cloud Vision AI (content safety)
- [x] BigQuery Export - wardrobe_items
- [x] BigQuery Export - users
- [x] BigQuery Export - style_personas
- [x] BigQuery Export - recommendations

### ⏳ Ready to Install (Mentioned but Not Installed)
- [ ] Build Chatbot with Gemini API (AI fashion assistant)
- [ ] Detect Objects with Cloud Vision AI (verify clothing items)
- [ ] Trigger Email from Firestore (SendGrid - transactional emails)
- [ ] Firestore Counter (efficient item counting)
- [ ] Analyze Comment Toxicity (Perspective API - when adding chat/comments)

### 📦 Future Extensions (Not Priority)
- [ ] Translate Text in Firestore (multi-language support)
- [ ] Semantic Search with Vertex AI (advanced search)
- [ ] Reverse Image Search (find similar items)

---

## Monitoring

**Check extension logs**:
1. Firebase Console → Extensions
2. Click extension name
3. View logs in Cloud Functions

**Query results**:
```dart
// Check image labels
final labels = await FirebaseFirestore.instance
  .collection('imageLabels')
  .where('path', isEqualTo: 'users/$userId/wardrobe/image.jpg')
  .get();

// Check chat messages
final messages = await FirebaseFirestore.instance
  .collection('chatMessages')
  .where('sessionId', isEqualTo: sessionId)
  .orderBy('timestamp')
  .get();
```
