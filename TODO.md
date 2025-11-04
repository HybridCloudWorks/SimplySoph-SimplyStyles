# Project TODO & Development Phases

This document outlines the planned features and the development progress of the SimplyStyles application. It is divided into phases, with completed items checked off.

## Phase 1: Foundation & Authentication (Completed)

This phase focused on setting up the basic project structure, integrating Firebase, and implementing the core user authentication system.

- [x] Set up the Firebase project and integrate it with the Flutter application.
- [x] Implement user authentication (sign-up and login) using Firebase Authentication.
- [x] Create a dedicated `AuthService` to encapsulate all authentication-related logic, keeping the UI clean.
- [x] Build placeholder UI for the `LoginScreen` and `HomeScreen`.
- [x] Write a suite of widget tests to ensure the authentication flow is working correctly under various conditions (logged in, logged out).

## Phase 2: Onboarding Flow Architecture (Completed)

This phase established the logic for handling new users after they sign up, guiding them toward an onboarding process before they can access the main application.

- [x] Create a `DatabaseService` to manage all non-authentication-related interactions with Cloud Firestore.
- [x] Implement the critical "gatekeeper" widget (`AuthWrapper`) that intelligently routes users based on both their authentication and onboarding status.
- [x] Create a placeholder `OnboardingScreen` to serve as the entry point for the new user style quiz.
- [x] Add the `completeOnboarding` method to the `DatabaseService` and connect it to a button on the `OnboardingScreen` to finalize the onboarding process.
- [x] Write comprehensive widget tests to verify the new, more complex navigation logic, ensuring users are routed correctly based on their `onboardingComplete` status in Firestore.

## Phase 3: Multi-Page Onboarding UI & State

This phase will transform the placeholder onboarding screen into a multi-page, swipeable "style quiz" and create a centralized state management solution for the onboarding flow.

- [ ] **Step 1: The UI Skeleton (PageView)**
    - [ ] In `lib/screens/onboarding/onboarding_screen.dart`, add a `PageController` to manage the `PageView` state.
    - [ ] Replace the current `Scaffold` body with a `PageView` widget to create the swipeable screen effect.
    - [ ] Add temporary, colored `Container` widgets as the initial pages to visually confirm the `PageView` is working.

- [ ] **Step 2: The State "Brain" (ChangeNotifier)**
    - [ ] Create the file `lib/state/onboarding_state.dart`.
    - [ ] Inside the new file, define an `OnboardingState` class that mixes in `ChangeNotifier`.
    - [ ] Add the initial state properties required for the AI, such as `stylePreference` and `favoriteColors`, along with methods to update them (`setStyle`, `toggleColor`).
    - [ ] In `onboarding_screen.dart`, wrap the `Scaffold` in a `ChangeNotifierProvider` to make the `OnboardingState` available to all pages within the `PageView`.

## Phase 4: Onboarding "AI Questions"

This phase involves building the individual pages of the style quiz, each focusing on a specific question to gather user preferences.

- [ ] **Step 3: The "AI Questions" (The Pages)**
    - [ ] Create a `style_page.dart` widget that allows users to select their preferred style.
    - [ ] Create a `color_page.dart` widget with a grid of color swatches for users to pick their favorites.
    - [ ] Create a `goal_page.dart` widget for users to specify what they want to get out of the app.

## Phase 5: Finalize Onboarding & Data Persistence

This final phase will connect the data gathered during the onboarding quiz to the backend, saving the user's preferences and completing the onboarding flow.

- [ ] **Step 4: The "Save & Finish" (The DatabaseService)**
    - [ ] In `DatabaseService`, create a new method: `Future<void> saveOnboardingData(String uid, Map<String, dynamic> data)`.
    - [ ] On the final page of the `PageView`, implement the "Finish" button's `onPressed` logic:
        - [ ] Retrieve the collected data from the `OnboardingState` provider.
        - [ ] Call the new `saveOnboardingData` method in the `DatabaseService` to persist the user's choices to Firestore.
        - [ ] Call the existing `completeOnboarding` method to flag the user as fully onboarded, triggering the automatic navigation to the `HomeScreen`.
