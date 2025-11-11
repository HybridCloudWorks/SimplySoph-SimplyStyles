# SimplyStyles - Your AI-Powered Wardrobe Assistant

[![CI/CD](https://github.com/saulpatinojr/SimplySoph-SimplyStyles/actions/workflows/firebase-hosting-deploy.yml/badge.svg)](https://github.com/saulpatinojr/SimplySoph-SimplyStyles/actions/workflows/firebase-hosting-deploy.yml)
[![Firebase Hosting](https://img.shields.io/badge/Firebase-Hosting-orange?logo=firebase)](https://simplysoph-66c78.web.app)

## About The Project

SimplyStyles is a Flutter-based mobile application designed to revolutionize how users interact with their wardrobe. It acts as a personal stylist in your pocket, leveraging the power of AI to provide personalized outfit recommendations, help organize your closet, and assist you in discovering new styles tailored to your unique preferences.

The core mission is to make fashion simple, accessible, and fun for everyone, removing the daily "what to wear" dilemma.

## Current Progress & Implemented Features

As of now, the foundational structure of the application is in place, focusing on user authentication and the initial onboarding pipeline.

### Core Architecture

*   **Firebase Integration**: The project is fully integrated with Firebase for backend services.
*   **Authentication**: User sign-up and login functionality are implemented using **Firebase Authentication**. A dedicated `AuthService` handles all authentication-related logic, providing a clean interface for the UI.
*   **Database**: **Cloud Firestore** is used as the database. A `DatabaseService` is set up to manage all interactions with Firestore, such as fetching and updating user data.
*   **State Management**: The app uses the `provider` package for state management, allowing for a clean separation of concerns between the UI and the application logic.

### User Flow & Navigation

The application features a robust "gatekeeper" widget (`AuthWrapper`) that directs users to the appropriate screen based on their authentication and onboarding status:

1.  **Logged Out Users**: Are directed to the `LoginScreen`.
2.  **Logged In, Not Onboarded Users**: Are directed to the `OnboardingScreen`. This is where they will input their style preferences.
3.  **Logged In, Onboarded Users**: Are taken directly to the `HomeScreen` (placeholder).

This routing is handled reactively by streaming user data from Firestore, ensuring the UI always reflects the user's current state.

### Testing

The project includes a suite of widget tests to guarantee the reliability of the core authentication and navigation flow. These tests use `firebase_auth_mocks` and `fake_cloud_firestore` to simulate Firebase services, ensuring that:
*   Logged-out users see the `LoginScreen`.
*   Logged-in and fully onboarded users see the `HomeScreen`.
*   Logged-in users who have not completed the new user quiz are correctly shown the `OnboardingScreen`.

## Technology Stack

*   **Framework**: Flutter
*   **Backend**: Firebase
    *   Firebase Authentication
    *   Cloud Firestore
*   **State Management**: `provider`
*   **Testing**: `flutter_test`, `firebase_auth_mocks`, `fake_cloud_firestore`
*   **CI/CD**: GitHub Actions with automated testing, building, and Firebase deployment

## Deployment

The app is automatically deployed to Firebase Hosting on every push to the `main` branch.

- **Live App**: https://simplysoph-66c78.web.app
- **Setup Guide**: See [CI_CD_SETUP.md](CI_CD_SETUP.md)
- **Deployment Checklist**: See [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)

### Quick Start for CI/CD

```bash
# Windows: Run the setup script
scripts\setup-cicd.bat

# Linux/Mac: Run the bash script
bash scripts/create_firebase_service_account.sh simplysoph-66c78 github-actions-deploy
```
