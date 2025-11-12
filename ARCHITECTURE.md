# SimplyStyles Architecture

## System Overview

SimplyStyles follows a **client-server architecture** with Flutter as the frontend and Firebase as the backend-as-a-service (BaaS).

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Application                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   UI     │  │  State   │  │ Services │  │  Models  │   │
│  │ Screens  │◄─┤ Provider │◄─┤ Business │◄─┤   Data   │   │
│  │          │  │          │  │  Logic   │  │ Entities │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │ Firebase SDK
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Firebase Services                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Auth   │  │Firestore │  │ Storage  │  │Functions │   │
│  │          │  │          │  │          │  │          │   │
│  └──────────┘  └──────────┘  └──────────┘  └────┬─────┘   │
└──────────────────────────────────────────────────┼──────────┘
                                                    │
                                                    ▼
                                          ┌──────────────────┐
                                          │  Gemini AI API   │
                                          │  Image Analysis  │
                                          └──────────────────┘
```

## Architecture Layers

### 1. Presentation Layer (UI)

**Location**: `lib/screens/`

**Responsibility**: Display data and handle user interactions

**Components**:
- `auth/` - Login, signup screens
- `onboarding/` - User preference collection
- `home/` - Dashboard and navigation
- `closet/` - Wardrobe management
- `scanner/` - Image capture and upload
- `shop/` - Shopping recommendations
- `trends/` - Trend discovery

**Pattern**: Stateful/Stateless widgets with Consumer pattern for state

### 2. State Management Layer

**Location**: `lib/state/`

**Responsibility**: Manage application state

**Implementation**: Provider pattern

**Current States**:
- `OnboardingState` - User preferences during onboarding
- `AuthService` - Authentication state (also a service)

**Needed States**:
- `WardrobeState` - User's clothing items
- `PersonaState` - Style personas
- `AppState` - Global app settings

### 3. Business Logic Layer (Services)

**Location**: `lib/services/`

**Responsibility**: Core business logic and data operations

**Services**:

#### AuthService (`lib/auth/auth_service.dart`)
- User authentication (email, Google, Apple)
- Session management
- User state notifications

#### DatabaseService (`lib/services/database_service.dart`)
- User document operations
- Onboarding completion
- User data streams

#### FirestoreService (`lib/services/firestore_service.dart`)
- **Status**: Incomplete
- **Needed**: CRUD for wardrobe items, personas

#### GeminiCortexAPI (`lib/api/gemini_cortex_api.dart`)
- AI image analysis
- Persona generation
- Fit calculation

**Missing Services**:
- `WardrobeService` - Wardrobe item management
- `ImageService` - Image upload and processing
- `PersonaService` - Style persona operations
- `RecommendationService` - Outfit recommendations

### 4. Data Layer (Models)

**Location**: `lib/models/`

**Responsibility**: Data structures and serialization

**Models**:

#### ClothingItem
```dart
{
  id, userId, imageUrl, thumbnailUrl,
  category, color, dominantColors,
  brand, msrp, styleTag, tags,
  personaIds, scanMethod,
  createdAt, updatedAt
}
```

#### StylePersona
```dart
{
  id, userId, name, dominantStyle,
  colorPalette, priceRange, itemCount,
  itemIds, characteristics,
  createdAt, updatedAt
}
```

**Missing Models**:
- `User` - User profile data
- `Outfit` - Outfit combinations
- `Recommendation` - Shopping recommendations
- `Trend` - Fashion trends

### 5. Utility Layer

**Location**: `lib/utils/`

**Responsibility**: Helper functions and utilities

**Current**:
- `web_view_detector.dart` - Platform detection

**Needed**:
- Color utilities
- Image processing helpers
- Validation functions
- Date/time formatters

## Data Flow

### Authentication Flow
```
User Input → AuthService → Firebase Auth → User State Update → UI Rebuild
```

### Onboarding Flow
```
User Input → OnboardingState → FirestoreService → Firestore → AuthWrapper → Home
```

### Image Upload Flow (Planned)
```
Camera/Gallery → ImageService → Firebase Storage → Cloud Function → 
Gemini API → Analysis Results → Firestore → UI Update
```

### Persona Generation Flow (Planned)
```
Wardrobe Items → Cloud Function → Gemini API → 
Persona Calculation → Firestore → UI Update
```

## Firebase Architecture

### Collections Structure

```
users/
  {userId}/
    - email
    - displayName
    - photoURL
    - onboardingComplete
    - preferences: {}
    - createdAt
    - updatedAt

wardrobe_items/
  {itemId}/
    - userId
    - imageUrl
    - thumbnailUrl
    - category
    - color
    - dominantColors: []
    - brand
    - msrp
    - styleTag
    - tags: []
    - personaIds: []
    - scanMethod
    - createdAt
    - updatedAt

style_personas/
  {personaId}/
    - userId
    - name
    - dominantStyle
    - colorPalette: []
    - priceRange: {min, max}
    - itemCount
    - itemIds: []
    - characteristics: {}
    - createdAt
    - updatedAt

recommendations/
  {recommendationId}/
    - userId
    - itemId
    - score
    - reason
    - affiliateLink
    - createdAt
    - expiresAt

trends/
  {trendId}/
    - name
    - description
    - imageUrl
    - popularity
    - tags: []
    - createdAt
```

### Storage Structure

```
users/
  {userId}/
    wardrobe/
      original/
        {itemId}.jpg
      thumbnails/
        {itemId}_thumb.jpg
    profile/
      avatar.jpg
```

### Cloud Functions

```
functions/
  vortex_analyzeItem      - Analyze clothing image
  vortex_generatePersonas - Generate style personas
  vortex_calculateFit     - Calculate item fit score
  vortex_getRecommendations - Get shopping recommendations
```

## Security Architecture

### Authentication
- Firebase Authentication
- Email/Password, Google OAuth, Apple Sign-In
- Session management via Firebase SDK

### Authorization
- Firestore Security Rules
- User can only access own data
- Cloud Functions validate userId

### Data Privacy
- No PII stored in images
- Face/background redaction (planned)
- Encrypted data at rest (Firebase default)
- HTTPS only

### Security Rules

**Firestore**:
```javascript
// Users can only read/write their own data
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// Wardrobe items owned by user
match /wardrobe_items/{itemId} {
  allow read, write: if resource.data.userId == request.auth.uid;
}
```

**Storage**:
```javascript
// Users can only access their own files
match /users/{userId}/{allPaths=**} {
  allow read, write: if request.auth.uid == userId
    && request.resource.size < 10MB
    && request.resource.contentType.matches('image/.*');
}
```

## Scalability Considerations

### Current Scale
- **Users**: 0-10K (MVP)
- **Requests**: <1K/day
- **Storage**: <1GB

### Future Scale (100K users)
- **Users**: 100K
- **Requests**: ~1M/day
- **Storage**: ~100GB
- **Firestore Reads**: ~10M/day

### Optimization Strategies
1. **Caching**: Cache user data locally
2. **Pagination**: Limit query results
3. **Thumbnails**: Use compressed images
4. **CDN**: Firebase Hosting CDN
5. **Indexes**: Firestore composite indexes
6. **Rate Limiting**: Cloud Functions quotas

## Technology Decisions

### Why Flutter?
- Cross-platform (Web, iOS, Android, Desktop)
- Single codebase
- Fast development
- Material Design 3 support

### Why Firebase?
- Rapid development
- Managed infrastructure
- Built-in authentication
- Real-time database
- Serverless functions
- Free tier for MVP

### Why Provider?
- Simple state management
- Flutter recommended
- Good for small-medium apps
- Easy to test

### Why Gemini API?
- Advanced image recognition
- Natural language processing
- Google integration
- Competitive pricing

## Development Patterns

### Dependency Injection
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthService()),
    Provider(create: (_) => DatabaseService()),
  ],
  child: App(),
)
```

### Error Handling
```dart
try {
  await service.operation();
} on FirebaseException catch (e) {
  // Handle Firebase errors
} catch (e) {
  // Handle generic errors
}
```

### Async Operations
```dart
Future<void> loadData() async {
  setState(() => isLoading = true);
  try {
    final data = await service.getData();
    setState(() => this.data = data);
  } finally {
    setState(() => isLoading = false);
  }
}
```

### Stream Handling
```dart
StreamBuilder<DocumentSnapshot>(
  stream: databaseService.getUserStream(uid),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return DataWidget(snapshot.data);
    }
    return LoadingWidget();
  },
)
```

## Testing Strategy

### Unit Tests
- Test services in isolation
- Mock Firebase dependencies
- Test business logic

### Widget Tests
- Test UI components
- Test user interactions
- Test state changes

### Integration Tests
- Test complete flows
- Test Firebase integration
- Test navigation

## Performance Considerations

### App Size
- Current: ~15MB (web)
- Target: <20MB (web), <50MB (mobile)

### Load Time
- Current: ~2s (web)
- Target: <1s (web), <3s (mobile)

### Memory Usage
- Target: <100MB (mobile)

### Battery Usage
- Minimize background tasks
- Efficient image processing
- Cache aggressively

## Deployment Architecture

### Environments
- **Development**: Local + Firebase Emulators
- **Staging**: Firebase project (staging)
- **Production**: Firebase project (simplysoph-66c78)

### CI/CD Pipeline
```
Push to main → GitHub Actions → 
  Run Tests → Build → Deploy to Firebase Hosting
```

### Monitoring
- Firebase Analytics (planned)
- Crashlytics (planned)
- Performance Monitoring (planned)

## Future Architecture Considerations

### Microservices (V2.0+)
- Separate AI service
- Separate recommendation engine
- Separate analytics service

### Database Migration (If needed)
- Consider PostgreSQL for complex queries
- Keep Firebase for real-time features

### CDN for Images
- CloudFlare or similar
- Reduce Firebase Storage costs

### Caching Layer
- Redis for frequently accessed data
- Reduce Firestore reads

---

**Last Updated**: 2024  
**Next Review**: After V1.0 launch
