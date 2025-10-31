# SimplyStyles

**An AI-Powered Wardrobe Assistant for Gen Z Fashionistas**

SimplyStyles is a mobile application built with Flutter and Firebase that helps users digitize their closet, analyze their fashion style, and receive personalized recommendations powered by Gemini Cortex AI.

## Features

### Smart Closet
- **Barcode Scanning**: Auto-fetch brand, item type, color, and MSRP
- **Photo Scanning**: AI-powered image recognition with background removal
- **Manual Editing**: Override and customize item tags

### Style Persona Engine
- **AI Analysis**: Gemini Cortex AI analyzes your wardrobe to identify style patterns
- **Persona Generation**: Creates unique style personas based on your items
- **Customization**: View, name, edit, and merge personas

### Persona-Fit Scanner
- **Live Camera**: Real-time scanning of new items
- **AI Matching**: Calculates how well items fit your existing personas
- **Smart Verdicts**: Get instant feedback with match percentages

### Trend Wall
- **Curated Trends**: Discover emerging fashion aesthetics
- **Wardrobe Matching**: See which trends align with your current items
- **Persona Creation**: Build new personas based on trending styles

### Personalized Recommendations
- **Persona-Based Shopping**: Recommendations organized by your style personas
- **Smart Suggestions**: AI-powered item suggestions to expand your wardrobe

## Technology Stack

### Frontend
- **Flutter 3.x**: Cross-platform mobile framework
- **Dart 3.x**: Programming language
- **Provider**: State management
- **Material Design 3**: UI components

### Backend
- **Firebase Authentication**: User management
- **Cloud Firestore**: NoSQL database
- **Firebase Storage**: Image storage
- **Cloud Functions**: Serverless backend logic
- **Gemini Cortex AI**: Core AI intelligence

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Firebase CLI
- Node.js (18 or higher)
- A Firebase project
- Gemini Cortex AI API credentials

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/simplystyles.git
   cd simplystyles
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Create a Firestore database
   - Set up Firebase Storage
   - Download and add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

4. **Configure Gemini Cortex AI**
   - Update `lib/api/gemini_cortex_api.dart` with your API endpoint and key
   - Set the API key in Firebase Functions config:
     ```bash
     firebase functions:config:set gemini.apikey="YOUR_API_KEY"
     ```

5. **Deploy Firebase Functions**
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   cd ..
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── api/
│   └── gemini_cortex_api.dart   # Gemini Cortex AI integration
├── auth/
│   └── auth_service.dart        # Authentication logic
├── models/
│   ├── clothing_item.dart       # Clothing item data model
│   └── style_persona.dart       # Style persona data model
├── screens/
│   ├── auth/                    # Login and signup screens
│   ├── home/                    # Dashboard
│   ├── closet/                  # Smart closet
│   ├── scanner/                 # Persona-fit scanner
│   ├── trends/                  # Trend wall
│   └── shop/                    # Recommendations
├── services/
│   └── firestore_service.dart   # Database operations
└── widgets/                     # Reusable UI components

functions/
└── src/
    └── index.js                 # Cloud Functions
```

## Firebase Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /wardrobe_items/{itemId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /style_personas/{personaId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /trends/{trendId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Fashion Style Classification

SimplyStyles uses three core Gen Z fashion trends:

1. **Luxury Loungewear**: Premium-priced, comfortable clothing worn as everyday fashion
2. **New Preppy**: Bright colors, playful prints, matching sets (e.g., Roller Rabbit)
3. **Coastal Comfort**: Relaxed, beach-inspired streetwear (e.g., Aviator Nation, Pink Palm Puff)

## API Integration

The app integrates with Gemini Cortex AI for:
- Image analysis and clothing attribute extraction
- Style persona generation through clustering
- Persona-fit calculations
- Trend analysis and discovery

## Development Roadmap

- [ ] Implement barcode scanning functionality
- [ ] Add background removal for clothing images
- [ ] Integrate product lookup APIs
- [ ] Implement social sharing features
- [ ] Add outfit generator
- [ ] Integrate shopping affiliate links
- [ ] Add AR virtual try-on
- [ ] Implement sustainability scoring

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

For questions or issues, please open an issue on GitHub or contact the development team.

---

**Built with ❤️ for Gen Z fashionistas**
