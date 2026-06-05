# Flutter Firebase Skeleton

A forkable Flutter + Firebase starter app with authentication, user profiles, onboarding, localization, and app lock — ready for your own project.

Built with **Cupertino (iOS-style)** widgets and **Provider** for state management.

## Features

- **Authentication** — Email/password sign-in & registration, Google Sign-In
- **User Profiles** — Firestore-backed profiles with avatar upload (Firebase Storage)
- **Onboarding Flow** — Collect user info on first launch
- **App Lock** — PIN + biometric authentication with configurable timeout
- **Localization** — English & Turkish (built with Flutter's l10n)
- **Settings** — Language switcher, app lock config, sign out
- **iOS-style UI** — Uses Cupertino widgets throughout

## Firebase Setup

1. Create a Firebase project at [firebase.google.com](https://firebase.google.com)
2. Enable **Email/Password** and **Google** sign-in in Authentication > Sign-in method
3. Register your app (iOS, Android, web) in Project settings
4. Download `GoogleService-Info.plist` (iOS) and `google-services.json` (Android) — **don't commit these**
5. Install [FlutterFire CLI](https://firebase.flutter.dev/docs/cli) and run:

```bash
flutterfire configure
```

This generates `lib/firebase_options.dart` (already gitignored).

## Getting Started

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # Entry point + AuthWrapper
├── firebase_options.dart     # Auto-generated (gitignored)
├── l10n/                     # Localization files
├── models/
│   └── user_profile.dart     # UserProfile model
├── pages/
│   ├── home_page.dart        # Home tab
│   ├── login_page.dart       # Login/Register
│   ├── main_screen.dart      # Bottom nav wrapper
│   ├── onboarding_page.dart  # First-launch setup
│   ├── profile_page.dart     # Edit profile
│   ├── settings_page.dart    # App settings + lock config
│   ├── diet_page.dart        # Placeholder
│   ├── exercise_page.dart    # Placeholder
│   └── progress_page.dart    # Placeholder
├── services/
│   ├── auth_service.dart     # Firebase Auth logic
│   ├── user_profile_service.dart  # Firestore profiles
│   ├── storage_service.dart  # Firebase Storage
│   ├── app_lock_service.dart # PIN/biometric lock
│   └── language_service.dart # Locale persistence
└── widgets/
    ├── lock_wrapper.dart     # App lock gate
    └── profile_picture_widget.dart  # Avatar display
```

## Forking

This is designed to be **forked and customized**. To make it your own:

1. Fork this repo
2. Run `flutterfire configure` to connect your Firebase project
3. Update the app name in `pubspec.yaml` and platform configs
4. Remove placeholder pages (diet, exercise, progress) or replace with your own
5. Add or remove Firebase services as needed

## Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Authentication |
| `cloud_firestore` | User profile storage |
| `firebase_storage` | Avatar uploads |
| `google_sign_in` | Google Sign-In |
| `sign_in_with_apple` | Apple Sign-In (iOS/macOS) |
| `provider` | State management |
| `shared_preferences` | Local settings persistence |
| `local_auth` | Biometric authentication |
| `image_picker` | Avatar photo selection |

## License

MIT — see [LICENSE](LICENSE).
