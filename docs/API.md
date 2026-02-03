# API Documentation

## Overview

SimplyStyles uses Firebase Cloud Functions as its backend API layer. All functions are callable via the Firebase SDK.

**Base URL**: `https://us-central1-simplysoph-66c78.cloudfunctions.net`

## Authentication

All API calls require Firebase Authentication. The user's ID token is automatically included by the Firebase SDK.

```dart
// Authentication is handled automatically
final callable = FirebaseFunctions.instance.httpsCallable('functionName');
final result = await callable.call(parameters);
```

## Cloud Functions

### 1. vortex_analyzeItem

**Purpose**: Analyze a clothing item image using AI

**Method**: POST

**Parameters**:

```typescript
{
  imageUrl: string; // Firebase Storage URL or public URL
}
```

**Response**:

```typescript
{
  success: boolean;
  data: {
    category: string;           // 'top' | 'bottom' | 'dress' | 'shoes' | 'accessory'
    color: string;              // Primary color hex code
    dominantColors: string[];   // Array of hex codes
    brand?: string;             // Detected brand (if any)
    msrp?: number;             // Estimated price
    styleTag: string;           // 'casual' | 'formal' | 'sporty' | 'chic'
    tags: string[];             // Additional attributes
    confidence: number;         // 0-1 confidence score
    attributes: object;         // Raw AI response
  };
  error?: string;
}
```

**Example**:

```dart
final callable = functions.httpsCallable('vortex_analyzeItem');
final result = await callable.call({
  'imageUrl': 'https://storage.googleapis.com/...'
});

final data = result.data;
print('Category: ${data['category']}');
print('Color: ${data['color']}');
```

**Error Codes**:

- `invalid-argument` - Missing or invalid imageUrl
- `unauthenticated` - User not authenticated
- `internal` - AI analysis failed

---

### 2. vortex_generatePersonas

**Purpose**: Generate style personas based on user's wardrobe

**Method**: POST

**Parameters**: None (uses authenticated user's data)

**Response**:

```typescript
{
  success: boolean;
  data: {
    personas: Array<{
      name: string;
      dominantStyle: string;
      colorPalette: string[];
      priceRange: { min: number; max: number };
      itemCount: number;
      itemIds: string[];
      characteristics: {
        formality: number;
        boldness: number;
        sustainability: number;
        trendiness: number;
      };
    }>;
    primaryPersonaId: string;
  };
  error?: string;
}
```

**Example**:

```dart
final callable = functions.httpsCallable('vortex_generatePersonas');
final result = await callable.call();

final personas = result.data['personas'];
print('Generated ${personas.length} personas');
```

**Requirements**:

- User must have at least 15 wardrobe items
- Items must have AI analysis completed

**Error Codes**:

- `failed-precondition` - Not enough items
- `unauthenticated` - User not authenticated
- `internal` - Persona generation failed

---

### 3. vortex_calculateFit

**Purpose**: Calculate how well an item fits user's style personas

**Method**: POST

**Parameters**:

```typescript
{
  itemAttributes: {
    category: string;
    color: string;
    styleTag: string;
    tags: string[];
    price?: number;
  };
}
```

**Response**:

```typescript
{
  success: boolean;
  data: {
    overallFit: number;        // 0-1 overall fit score
    personaFits: Array<{
      personaId: string;
      personaName: string;
      fitScore: number;        // 0-1 fit score
      reasons: string[];       // Why it fits/doesn't fit
    }>;
    recommendation: 'strong_match' | 'good_match' | 'weak_match' | 'no_match';
  };
  error?: string;
}
```

**Example**:

```dart
final callable = functions.httpsCallable('vortex_calculateFit');
final result = await callable.call({
  'itemAttributes': {
    'category': 'top',
    'color': '#000000',
    'styleTag': 'chic',
    'tags': ['v-neck', 'cotton'],
    'price': 49.99
  }
});

final fitScore = result.data['overallFit'];
print('Fit score: ${(fitScore * 100).toInt()}%');
```

**Error Codes**:

- `invalid-argument` - Missing required attributes
- `failed-precondition` - User has no personas
- `unauthenticated` - User not authenticated

---

### 4. vortex_getRecommendations (Planned)

**Purpose**: Get personalized shopping recommendations

**Method**: POST

**Parameters**:

```typescript
{
  personaId?: string;        // Optional: specific persona
  category?: string;         // Optional: filter by category
  maxPrice?: number;         // Optional: price limit
  limit?: number;            // Default: 20
}
```

**Response**:

```typescript
{
  success: boolean;
  data: {
    recommendations: Array<{
      productName: string;
      productImage: string;
      productUrl: string;
      price: number;
      brand: string;
      category: string;
      fitScore: number;
      reason: string;
    }>;
  };
  error?: string;
}
```

---

### 5. vortex_generateOutfit (Planned)

**Purpose**: Generate outfit combinations from user's wardrobe

**Method**: POST

**Parameters**:

```typescript
{
  occasion?: string;         // 'work' | 'casual' | 'formal' | 'date'
  season?: string;           // 'spring' | 'summer' | 'fall' | 'winter'
  personaId?: string;        // Optional: specific persona
}
```

**Response**:

```typescript
{
  success: boolean;
  data: {
    outfits: Array<{
      itemIds: string[];
      score: number;
      reason: string;
    }>;
  };
  error?: string;
}
```

---

## Firebase SDK Usage

### Initialize Firebase Functions

```dart
import 'package:cloud_functions/cloud_functions.dart';

final functions = FirebaseFunctions.instance;

// For development (use emulator)
// functions.useFunctionsEmulator('localhost', 5001);
```

### Call a Function

```dart
Future<Map<String, dynamic>> analyzeImage(String imageUrl) async {
  try {
    final callable = functions.httpsCallable('vortex_analyzeItem');
    final result = await callable.call({'imageUrl': imageUrl});
    return result.data;
  } on FirebaseFunctionsException catch (e) {
    print('Error: ${e.code} - ${e.message}');
    rethrow;
  }
}
```

### Handle Errors

```dart
try {
  final result = await callable.call(params);
} on FirebaseFunctionsException catch (e) {
  switch (e.code) {
    case 'invalid-argument':
      // Handle invalid input
      break;
    case 'unauthenticated':
      // Handle auth error
      break;
    case 'failed-precondition':
      // Handle precondition error
      break;
    default:
      // Handle other errors
      break;
  }
}
```

## Rate Limits

### Current Limits (MVP)

- **Analyze Item**: 100 calls/day per user
- **Generate Personas**: 10 calls/day per user
- **Calculate Fit**: 500 calls/day per user

### Future Limits (Production)

- **Analyze Item**: 1000 calls/day per user
- **Generate Personas**: 50 calls/day per user
- **Calculate Fit**: Unlimited

## Pricing

### Firebase Functions

- **Free Tier**: 2M invocations/month
- **Paid**: $0.40 per million invocations

### Gemini API

- **Free Tier**: 60 requests/minute
- **Paid**: $0.00025 per request

## Testing

### Using Firebase Emulator

```bash
# Start emulator
firebase emulators:start --only functions

# In Dart code
FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
```

### Mock Responses

```dart
// For testing
class MockGeminiAPI extends GeminiCortexAPI {
  @override
  Future<Map<String, dynamic>> analyzeClothingImage(String imageUrl) async {
    return {
      'category': 'top',
      'color': '#000000',
      'styleTag': 'chic',
      'confidence': 0.95
    };
  }
}
```

## Security

### Authentication

- All functions require Firebase Authentication
- User ID is automatically validated

### Authorization

- Functions only access data owned by authenticated user
- Admin functions require custom claims

### Input Validation

- All inputs are validated server-side
- Sanitized before processing

### Rate Limiting

- Implemented via Firebase quotas
- Per-user limits enforced

## Monitoring

### Metrics Tracked

- Function invocations
- Execution time
- Error rate
- Success rate

### Alerts

- Error rate > 5%
- Execution time > 10s
- Daily quota exceeded

## Changelog

### Version 1.0 (Current)

- `vortex_analyzeItem` - Initial implementation
- `vortex_generatePersonas` - Initial implementation
- `vortex_calculateFit` - Initial implementation

### Version 1.1 (Planned)

- `vortex_getRecommendations` - New function
- `vortex_generateOutfit` - New function
- Rate limiting improvements

---

**Last Updated**: 2024  
**API Version**: 1.0
