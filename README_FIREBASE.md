Firebase setup and CI/CD checklist for SimplyStyles

1. Firebase Project

- Create a Firebase project in the Firebase Console (https://console.firebase.google.com/).
- Note the Project ID (you'll need it for GitHub secrets and hosting setup).

2. Web App Registration

- In Firebase Console > Project Settings > General > Your apps, register a Web app if not already done.
- Add the Firebase config to `lib/firebase_options.dart` (the FlutterFire CLI can generate this automatically: `flutterfire configure`).

3. Authentication

- Go to Firebase Console > Authentication > Sign-in method.
- Enable Google and Apple sign-in providers.
- Under Authorized domains, ensure `localhost` and your production domain (e.g., `example.web.app` or `example.firebaseapp.com`) are listed.
- If you use redirects with custom domains, add the domain to OAuth redirect domains.

4. Firestore & Storage

- Enable Firestore; set rules that match your security needs. For testing, you may use permissive rules but lock them before production.
- Enable Storage if needed and set appropriate rules.

5. Firebase Hosting

- In the Firebase Console, add a Hosting site and follow instructions to deploy the `build/web` from your Flutter web build.

6. Service account & GitHub Secrets (for CI/CD)

- Create a service account with the `Firebase Hosting Admin` (or `Editor`) role.
- Generate a JSON key for that service account.
- In your GitHub repository settings > Secrets > Actions, add:
  - `FIREBASE_SERVICE_ACCOUNT` : full JSON key contents (escaped as a single-line string)
  - `FIREBASE_PROJECT_ID` : your Firebase project id
  - `FIREBASE_TOKEN` : (optional) CI token created with `firebase login:ci` if you prefer token-based deploys

7. Test locally

- Run the app in Chrome/Edge and test Google sign-in flows.
- If popups are blocked, confirm redirect fallback behavior works.

8. Deploy

- Push to `main` to trigger the GitHub Action.
- Inspect the Action logs and Firebase Hosting site.

9. Production checklist

- Verify OAuth consent screen on GCP Console (for Google sign-in) is configured for production.
- Add privacy policy and terms of service as required by app stores.
- Configure Play Store / App Store signing and build pipelines.

---

If you want, I can:

- Run `flutterfire configure` in this repo (requires Firebase project access).
- Create the GCP service account and provide the JSON key (I can't create it from here, but I can give exact `gcloud` commands).
- Add a GitHub Action secret upload guide and sample `gcloud` commands to create the service account.
