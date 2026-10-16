# SimplyStyles ✨

> **AI-Powered Wardrobe Assistant for Gen-Z Fashion Creators**

[![CI/CD](https://github.com/HybridCloudWorks/SimplySoph-SimplyStyles/actions/workflows/firebase-hosting-deploy.yml/badge.svg)](https://github.com/HybridCloudWorks/SimplySoph-SimplyStyles/actions/workflows/firebase-hosting-deploy.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

## 🎯 What is SimplyStyles?

SimplyStyles is a **Flutter-based fashion app** designed for content creators and fashion enthusiasts aged 15-25. Upload photos of your clothes, and our AI analyzes them to:

- 🧥 **Organize your digital closet** with smart categorization
- 👗 **Generate style personas** based on your wardrobe patterns  
- 💡 **Recommend outfits** from your existing clothes
- 🛍️ **Discover new pieces** that match your style

**Live Demo**: none. There is no public deployment of this app yet.

---

## 📱 Features

### ✅ Implemented
| Feature | Description |
|---------|-------------|
| **Authentication** | Google Sign-In, Apple Sign-In, Email/Password |
| **Digital Closet** | Upload & organize clothing items with AI tagging |
| **AI Analysis** | Gemini-powered clothing detection (category, color, brand) |
| **Style Personas** | Auto-generated style profiles from wardrobe (5+ items) |
| **Onboarding Quiz** | Style preference & color selection |
| **Cloud Functions** | 9 serverless functions, including Gemini and Vision AI |

### 🚧 In Development
| Feature | Status | Issue |
|---------|--------|-------|
| Social Sharing | Not started | [#7](../../issues/7) |
| Profile/Settings | Not started | [#12](../../issues/12) |
| Dark Mode | Planned | [#17](../../issues/17) |
| Real Product Recommendations | Needs API keys | [#3](../../issues/3), [#5](../../issues/5) |

### 🐛 Known Issues
See our [Issues page](../../issues) for the full list. Key issues:
- **AI Integrations**: Shein/Zappos APIs need configuration ([#3](../../issues/3))
- **Mock Data**: Shop recommendations show placeholders ([#5](../../issues/5))
- **Navigation**: 5-tab structure needs redesign ([#9](../../issues/9))

---

## 🛠 Technology Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter 3.0+, Material 3 |
| **State Management** | Provider |
| **Backend** | Firebase (Auth, Firestore, Storage, Functions) |
| **AI/ML** | Google Gemini 3.8 Flash (Vertex AI), Google Cloud Vision |
| **External APIs** | RapidAPI (Shein, Zappos), Google Trends |
| **CI/CD** | GitHub Actions (test and build; manual Cloud Functions deploy) |

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+
- Firebase CLI
- Node.js 22 (for Cloud Functions)

### Installation

```bash
# Clone the repository
git clone https://github.com/HybridCloudWorks/SimplySoph-SimplyStyles.git
cd SimplySoph-SimplyStyles

# Install Flutter dependencies
flutter pub get

# Install Cloud Functions dependencies
cd functions && npm install && cd ..

# Run locally
flutter run -d chrome
```

### Configuration Required

1. **Firebase Project**: Already configured (simplysoph-66c78)
2. **RapidAPI Key** (for Shein/Zappos):
   ```bash
   firebase functions:config:set rapidapi.key="YOUR_KEY"
   ```
3. **Deploy Functions**: run the manual **CI/CD** workflow in GitHub Actions (Run workflow, on `main`). It deploys only this app's `simplystyles` functions codebase, with keyless Workload Identity Federation login. A project Owner first runs `scripts/setup-functions-deploy-identity.ps1` once. The Firebase project is shared with the SimplySoph website, so never deploy hosting or rules from this repo. See [Deployment](docs/Deployment.md#cloud-functions-deploy).

---

## 📂 Project Structure

```
lib/
├── auth/               # Authentication (AuthService, AuthWrapper)
├── models/             # Data models (ClothingItem, StylePersona)
├── screens/            # UI screens
│   ├── auth/           # Login/Register
│   ├── closet/         # Digital closet, item details
│   ├── home/           # Dashboard
│   ├── onboarding/     # Style quiz
│   ├── scanner/        # Add item via camera
│   └── shop/           # Recommendations
├── services/           # Business logic (13 services)
├── state/              # State management
└── utils/              # Helpers

functions/              # Firebase Cloud Functions (Node.js)
docs/                   # Documentation
test/                   # Widget & integration tests
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

Test files:
- `widget_test.dart` - Core widget tests
- `auth_service_test.dart` - Authentication flow
- `closet_upload_integration_test.dart` - Upload pipeline

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [Setup Guide](docs/Setup.md) | Environment setup |
| [Architecture](docs/Architecture.md) | System design |
| [AI Integration](docs/AI_INTEGRATION.md) | Vortex AI pipeline |
| [Database Schema](docs/Database.md) | Firestore models |
| [Deployment](docs/Deployment.md) | Deploy to production |
| [CI/CD](docs/CI_CD.md) | GitHub Actions pipeline |
| [Roadmap](docs/Roadmap.md) | Future features |

---

## 🤝 Contributing

1. Check [open issues](../../issues) for available tasks
2. Issues labeled `good first issue` are beginner-friendly
3. Priority is in the issue title: `[Critical]`, `[High]`, `[Medium]` or `[Low]`

### Labels
| Label | Meaning |
|-------|---------|
| `enhancement` | New feature |
| `bug` | Something broken |

---

## 📄 License

All rights reserved. See [LICENSE](LICENSE).

---

## 👩‍💻 Author

**SimplySoph** - Fashion content creator with 200k+ followers

Built with ❤️ for the fashion community
