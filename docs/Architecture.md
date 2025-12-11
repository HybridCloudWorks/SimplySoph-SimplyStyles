# Architecture

This document consolidates core architecture guidance.

## Contents

- System overview and layers
- Data flow and Firebase design
- Security and scalability

### Consolidated Sources

ARCHITECTURE.md → key architecture content merged below
WORKFLOW_DIAGRAM.md → CI/CD visuals referenced in CI_CD.md

---

# System Overview

SimplyStyles uses a Flutter client with Firebase BaaS and Gemini AI for analysis.

## Architecture Layers

- Presentation (`lib/screens/`)
- State (`lib/state/` via Provider)
- Services (`lib/services/`) including `AuthService`, `GeminiCortexAPI`
- Data models (`lib/models/`)
- Utilities (`lib/utils/`)

## Data Flow (key flows)

- Authentication → AuthService → Firebase Auth → UI update
- Onboarding → State → Firestore → AuthWrapper → Home
- Image Upload (planned) → Storage → Function → Gemini → Firestore

## Firebase Structure

- Collections: `users`, `wardrobe_items`, `style_personas`, `recommendations`, `trends`
- Storage: `users/{userId}/wardrobe/...`
- Functions: analyze item, generate personas, fit calculation, recommendations

## Security

- Firestore rules: user-isolation for `users`, `wardrobe_items`
- Storage rules: user-owned paths, image content-types, size limits

## Scalability & Ops

- Caching, pagination, thumbnails, CDN, indexes, rate-limiting
- Environments: dev (emulators), staging, production
- CI/CD via GitHub Actions (see docs/CI_CD.md)

## Technology Choices

- Flutter, Firebase, Provider, Gemini API

## Testing Strategy

- Unit, widget, integration tests; mocks for Firebase

## Performance Targets

- App size, load times, memory, battery usage

## Future Considerations

- Microservices, DB migration options, CDN, caching layer

---
