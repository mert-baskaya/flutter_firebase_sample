# Localization Guide for Turkish Translation

## Overview
The app is now set up for localization with support for English (en) and Turkish (tr). The localization infrastructure is complete, and you just need to translate the strings.

## Translation Files Location

**File to translate:** `lib/l10n/app_tr.arb`

This file contains all the user-facing strings in your app. Currently, it has English values that you need to replace with Turkish translations.

## How to Translate

Open the file `lib/l10n/app_tr.arb` and replace the English text with Turkish translations:

### Example:
```json
"welcomeBack": "Tekrar Hoş Geldiniz",
"createAccount": "Hesap Oluştur",
"email": "E-posta",
"password": "Şifre",
```

### All Strings to Translate (in app_tr.arb):

1. **appTitle** - Application title (line 4)
2. **welcomeBack** - "Welcome Back" (line 9)
3. **createAccount** - "Create Account" (line 14)
4. **email** - "Email" (line 19)
5. **password** - "Password" (line 24)
6. **pleaseEnterEmail** - "Please enter your email" (line 29)
7. **pleaseEnterValidEmail** - "Please enter a valid email" (line 34)
8. **pleaseEnterPassword** - "Please enter your password" (line 39)
9. **passwordMinLength** - "Password must be at least 6 characters" (line 44)
10. **signIn** - "Sign In" (line 49)
11. **signUp** - "Sign Up" (line 54)
12. **or** - "OR" (line 59)
13. **continueWithGoogle** - "Continue with Google" (line 64)
14. **dontHaveAccount** - "Don't have an account? Sign Up" (line 69)
15. **alreadyHaveAccount** - "Already have an account? Sign In" (line 74)
16. **home** - "Home" (line 79)
17. **profile** - "Profile" (line 84)
18. **welcome** - "Welcome!" (line 89)
19. **noEmail** - "No email" (line 94)
20. **emailVerified** - "Email Verified" (line 99)
21. **yes** - "Yes" (line 104)
22. **no** - "No" (line 109)
23. **accountCreated** - "Account Created" (line 114)
24. **unknown** - "Unknown" (line 119)
25. **lastSignIn** - "Last Sign In" (line 124)
26. **signOut** - "Sign Out" (line 129)

## After Translation

Once you've translated all strings in `app_tr.arb`, run:

```bash
flutter pub get
```

This will regenerate the localization files with your Turkish translations.

## Testing Your Translations

To test Turkish translations:
1. Change your device/emulator language to Turkish, OR
2. Add this to MaterialApp in main.dart (temporarily):
   ```dart
   locale: const Locale('tr'),
   ```

## Adding More Languages

To add another language (e.g., German):
1. Create `lib/l10n/app_de.arb` (copy from app_tr.arb)
2. Translate the strings
3. Add `Locale('de')` to `supportedLocales` in `lib/main.dart`
4. Run `flutter pub get`

## File Structure

```
lib/l10n/
├── app_en.arb              # English (template) - DO NOT EDIT
├── app_tr.arb              # Turkish - EDIT THIS FILE
├── app_localizations.dart  # Auto-generated - DO NOT EDIT
├── app_localizations_en.dart # Auto-generated - DO NOT EDIT
└── app_localizations_tr.dart # Auto-generated - DO NOT EDIT
```

## Important Notes

- Only edit `app_tr.arb`
- Do NOT edit the auto-generated `.dart` files
- Keep the JSON structure intact (only change values, not keys)
- The `@` entries are metadata - you can leave them as-is or translate descriptions
- After editing, always run `flutter pub get` to regenerate

## Where Strings Are Used

| String Key | Used In |
|------------|---------|
| appTitle | App title bar |
| welcomeBack, createAccount | Login page header |
| email, password | Login form fields |
| pleaseEnterEmail, pleaseEnterValidEmail, pleaseEnterPassword, passwordMinLength | Form validation |
| signIn, signUp | Login/register buttons |
| continueWithGoogle | Google sign-in button |
| dontHaveAccount, alreadyHaveAccount | Login/register toggle |
| home, profile | Bottom navigation and page titles |
| welcome | Home page greeting |
| emailVerified, accountCreated, lastSignIn | Profile information labels |
| yes, no | Status values |
| signOut | Logout button |
