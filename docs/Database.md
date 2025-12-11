# Database Schema Documentation

## Overview

SimplyStyles uses **Cloud Firestore** as its primary database. This document defines all collections, documents, and data structures.

## Collections

### 1. users

**Purpose**: Store user profile and preferences

**Document ID**: Firebase Auth UID

**Structure**:

```typescript
{
  email: string;
  displayName: string;
  photoURL?: string;
  provider: 'email' | 'google' | 'apple';
  onboardingComplete: boolean;
  preferences: {
    stylePreference?: string;
    favoriteColors?: string[];
    priceRange?: {
      min: number;
      max: number;
    };
    sizes?: {
      top?: string;
      bottom?: string;
      shoe?: string;
    };
  };
  stats: {
    itemCount: number;
    personaCount: number;
    lastActive: timestamp;
  };
  createdAt: timestamp;
  updatedAt: timestamp;
}
```

**Example**:

```json
{
  "email": "user@example.com",
  "displayName": "Jane Doe",
  "photoURL": "https://...",
  "provider": "google",
  "onboardingComplete": true,
  "preferences": {
    "stylePreference": "Chic",
    "favoriteColors": ["black", "white", "pink"],
    "priceRange": {
      "min": 50,
      "max": 200
    }
  },
  "stats": {
    "itemCount": 23,
    "personaCount": 2,
    "lastActive": "2024-01-15T10:30:00Z"
  },
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

**Indexes**:

- `email` (for lookups)
- `createdAt` (for analytics)

**Security Rules**:

```javascript
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}
```

---

### 2. wardrobe_items

**Purpose**: Store clothing items in user's wardrobe

**Document ID**: Auto-generated

**Structure**:

```typescript
{
  userId: string;              // Reference to users collection
  imageUrl: string;            // Full-size image URL
  thumbnailUrl: string;        // Thumbnail image URL
  category: string;            // 'top' | 'bottom' | 'dress' | 'shoes' | 'accessory'
  color: string;               // Primary color
  dominantColors: string[];    // Array of hex colors
  brand?: string;              // Brand name (if detected)
  msrp?: number;              // Retail price (if detected)
  styleTag: string;            // 'casual' | 'formal' | 'sporty' | 'chic'
  tags: string[];              // Additional tags
  personaIds: string[];        // Associated persona IDs
  scanMethod: 'camera' | 'upload' | 'barcode';
  aiAnalysis: {
    confidence: number;        // 0-1 confidence score
    attributes: object;        // Raw AI response
    processedAt: timestamp;
  };
  createdAt: timestamp;
  updatedAt: timestamp;
}
```

**Example**:

```json
{
  "userId": "user123",
  "imageUrl": "https://storage.../original/item456.jpg",
  "thumbnailUrl": "https://storage.../thumbnails/item456_thumb.jpg",
  "category": "top",
  "color": "#000000",
  "dominantColors": ["#000000", "#FFFFFF"],
  "brand": "Zara",
  "msrp": 49.99,
  "styleTag": "chic",
  "tags": ["v-neck", "cotton", "summer"],
  "personaIds": ["persona789"],
  "scanMethod": "camera",
  "aiAnalysis": {
    "confidence": 0.92,
    "attributes": {},
    "processedAt": "2024-01-15T10:30:00Z"
  },
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

**Indexes**:

- `userId` + `createdAt` (for user's wardrobe)
- `userId` + `category` (for filtering)
- `userId` + `styleTag` (for persona matching)

**Security Rules**:

```javascript
match /wardrobe_items/{itemId} {
  allow read, write: if request.auth.uid == resource.data.userId;
  allow create: if request.auth.uid == request.resource.data.userId;
}
```

---

### 3. style_personas

**Purpose**: Store user's style personas

**Document ID**: Auto-generated

**Structure**:

```typescript
{
  userId: string;
  name: string;                // User-defined or AI-generated
  dominantStyle: string;       // 'luxury_loungewear' | 'new_preppy' | 'coastal_comfort'
  colorPalette: string[];      // Hex color codes
  priceRange: {
    min: number;
    max: number;
  };
  itemCount: number;           // Number of items in this persona
  itemIds: string[];           // References to wardrobe_items
  characteristics: {
    formality: number;         // 0-1 scale
    boldness: number;          // 0-1 scale
    sustainability: number;    // 0-1 scale
    trendiness: number;        // 0-1 scale
  };
  generatedBy: 'ai' | 'user';
  isPrimary: boolean;          // Is this the primary persona?
  createdAt: timestamp;
  updatedAt: timestamp;
}
```

**Example**:

```json
{
  "userId": "user123",
  "name": "Work Chic",
  "dominantStyle": "new_preppy",
  "colorPalette": ["#000000", "#FFFFFF", "#C8A2C8"],
  "priceRange": {
    "min": 50,
    "max": 200
  },
  "itemCount": 15,
  "itemIds": ["item1", "item2", "item3"],
  "characteristics": {
    "formality": 0.8,
    "boldness": 0.4,
    "sustainability": 0.6,
    "trendiness": 0.7
  },
  "generatedBy": "ai",
  "isPrimary": true,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

**Indexes**:

- `userId` + `isPrimary` (for primary persona)
- `userId` + `createdAt` (for listing)

**Security Rules**:

```javascript
match /style_personas/{personaId} {
  allow read, write: if request.auth.uid == resource.data.userId;
  allow create: if request.auth.uid == request.resource.data.userId;
}
```

---

### 4. recommendations

**Purpose**: Store shopping recommendations

**Document ID**: Auto-generated

**Structure**:

```typescript
{
  userId: string;
  itemId?: string;             // Related wardrobe item (for "complete the look")
  personaId?: string;          // Related persona
  productName: string;
  productImage: string;
  productUrl: string;          // Affiliate link
  affiliateNetwork: string;    // 'amazon' | 'shopstyle' | etc.
  price: number;
  brand: string;
  category: string;
  fitScore: number;            // 0-1 how well it fits user's style
  reason: string;              // Why recommended
  tags: string[];
  status: 'active' | 'clicked' | 'purchased' | 'dismissed';
  createdAt: timestamp;
  expiresAt: timestamp;        // Recommendations expire after 7 days
}
```

**Example**:

```json
{
  "userId": "user123",
  "itemId": "item456",
  "personaId": "persona789",
  "productName": "Red Heels",
  "productImage": "https://...",
  "productUrl": "https://affiliate.link/...",
  "affiliateNetwork": "amazon",
  "price": 89.99,
  "brand": "Steve Madden",
  "category": "shoes",
  "fitScore": 0.95,
  "reason": "Completes your chic evening look",
  "tags": ["heels", "red", "formal"],
  "status": "active",
  "createdAt": "2024-01-15T10:30:00Z",
  "expiresAt": "2024-01-22T10:30:00Z"
}
```

**Indexes**:

- `userId` + `status` + `createdAt` (for active recommendations)
- `userId` + `expiresAt` (for cleanup)

**Security Rules**:

```javascript
match /recommendations/{recommendationId} {
  allow read: if request.auth.uid == resource.data.userId;
  allow write: if false; // Only Cloud Functions can write
}
```

---

### 5. trends

**Purpose**: Store fashion trends (global, not user-specific)

**Document ID**: Auto-generated

**Structure**:

```typescript
{
  name: string;
  description: string;
  imageUrl: string;
  category: string;
  tags: string[];
  popularity: number;          // 0-100 trending score
  demographics: {
    ageGroup: string[];        // ['18-24', '25-34']
    region: string[];          // ['US', 'EU']
  };
  relatedProducts: string[];   // Product URLs
  source: string;              // Where trend data came from
  isActive: boolean;
  createdAt: timestamp;
  updatedAt: timestamp;
}
```

**Example**:

```json
{
  "name": "Y2K Revival",
  "description": "Early 2000s fashion is back",
  "imageUrl": "https://...",
  "category": "style",
  "tags": ["y2k", "retro", "colorful"],
  "popularity": 85,
  "demographics": {
    "ageGroup": ["18-24", "25-34"],
    "region": ["US", "EU"]
  },
  "relatedProducts": ["https://..."],
  "source": "TikTok",
  "isActive": true,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

**Indexes**:

- `isActive` + `popularity` (for trending feed)
- `category` + `popularity` (for filtered trends)

**Security Rules**:

```javascript
match /trends/{trendId} {
  allow read: if request.auth != null;
  allow write: if false; // Only Cloud Functions can write
}
```

---

### 6. outfits (Future)

**Purpose**: Store outfit combinations

**Document ID**: Auto-generated

**Structure**:

```typescript
{
  userId: string;
  name: string;
  itemIds: string[];           // Array of wardrobe_item IDs
  occasion: string;            // 'work' | 'casual' | 'formal' | 'date'
  season: string;              // 'spring' | 'summer' | 'fall' | 'winter'
  personaId?: string;
  imageUrl?: string;           // Composite image
  wornCount: number;
  lastWorn?: timestamp;
  isFavorite: boolean;
  createdAt: timestamp;
  updatedAt: timestamp;
}
```

---

## Data Relationships

```
users (1) ──────┬──────> (N) wardrobe_items
                │
                └──────> (N) style_personas
                │
                └──────> (N) recommendations

style_personas (1) ────> (N) wardrobe_items (via itemIds)

wardrobe_items (1) ────> (N) style_personas (via personaIds)

recommendations (N) ───> (1) wardrobe_items (optional)
                    └──> (1) style_personas (optional)
```

## Query Patterns

### Get User's Wardrobe

```dart
firestore
  .collection('wardrobe_items')
  .where('userId', isEqualTo: userId)
  .orderBy('createdAt', descending: true)
  .limit(50)
```

### Get User's Primary Persona

```dart
firestore
  .collection('style_personas')
  .where('userId', isEqualTo: userId)
  .where('isPrimary', isEqualTo: true)
  .limit(1)
```

### Get Active Recommendations

```dart
firestore
  .collection('recommendations')
  .where('userId', isEqualTo: userId)
  .where('status', isEqualTo: 'active')
  .where('expiresAt', isGreaterThan: DateTime.now())
  .orderBy('fitScore', descending: true)
```

### Get Trending Items

```dart
firestore
  .collection('trends')
  .where('isActive', isEqualTo: true)
  .orderBy('popularity', descending: true)
  .limit(20)
```

## Data Migration Strategy

### Version 1.0 → 1.1

- Add `stats` field to users
- Backfill existing users with default stats

### Version 1.1 → 2.0

- Add `outfits` collection
- Migrate persona data structure

## Backup Strategy

- **Frequency**: Daily automated backups
- **Retention**: 30 days
- **Method**: Firebase automatic backups
- **Recovery**: Point-in-time restore

## Data Retention

- **User Data**: Retained until account deletion
- **Wardrobe Items**: Retained until user deletes
- **Recommendations**: Auto-delete after 30 days
- **Trends**: Archive after 90 days of inactivity

## Privacy Considerations

- No PII in images
- User email encrypted at rest
- Data export available on request
- Account deletion removes all user data

---

**Last Updated**: 2024  
**Schema Version**: 1.0
