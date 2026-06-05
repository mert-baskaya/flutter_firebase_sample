import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Firebase Auth Demo'**
  String get appTitle;

  /// Welcome back message on login page
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Create account header on registration
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Email format validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Divider text between authentication methods
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Google sign-in button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Text to switch to registration
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// Text to switch to login
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// Home page title and navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Profile page title and navigation label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Welcome message on home page
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// Fallback text when user has no email
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// Email verification status label
  ///
  /// In en, this message translates to:
  /// **'Email Verified'**
  String get emailVerified;

  /// Yes answer
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No answer
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Account creation date label
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get accountCreated;

  /// Fallback for unknown values
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Last sign-in time label
  ///
  /// In en, this message translates to:
  /// **'Last Sign In'**
  String get lastSignIn;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Diet navigation label and page title
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get diet;

  /// Exercise navigation label and page title
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// Progress navigation label and page title
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Diet page content
  ///
  /// In en, this message translates to:
  /// **'Diet Page'**
  String get dietPage;

  /// Exercise page content
  ///
  /// In en, this message translates to:
  /// **'Exercise Page'**
  String get exercisePage;

  /// Progress page content
  ///
  /// In en, this message translates to:
  /// **'Progress Page'**
  String get progressPage;

  /// Onboarding page title
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeYourProfile;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Complete button text
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Age question in onboarding
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get howOldAreYou;

  /// Age label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Age field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your age'**
  String get enterYourAge;

  /// Years unit
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// Age validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your age'**
  String get pleaseEnterAge;

  /// Number validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// Age minimum validation error
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old'**
  String get mustBeAtLeast18;

  /// Age range validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age'**
  String get pleaseEnterValidAge;

  /// Height question in onboarding
  ///
  /// In en, this message translates to:
  /// **'What is your height?'**
  String get whatIsYourHeight;

  /// Height label
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// Height field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your height'**
  String get enterYourHeight;

  /// Centimeters unit
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// Height validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your height'**
  String get pleaseEnterHeight;

  /// Height minimum validation error
  ///
  /// In en, this message translates to:
  /// **'Height must be at least 50 cm'**
  String get heightMinimum;

  /// Height maximum validation error
  ///
  /// In en, this message translates to:
  /// **'Height must be less than 300 cm'**
  String get heightMaximum;

  /// Weight question in onboarding
  ///
  /// In en, this message translates to:
  /// **'What is your weight?'**
  String get whatIsYourWeight;

  /// Weight label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Weight field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your weight'**
  String get enterYourWeight;

  /// Kilograms unit
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// Weight validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight'**
  String get pleaseEnterWeight;

  /// Weight minimum validation error
  ///
  /// In en, this message translates to:
  /// **'Weight must be at least 20 kg'**
  String get weightMinimum;

  /// Weight maximum validation error
  ///
  /// In en, this message translates to:
  /// **'Weight must be less than 500 kg'**
  String get weightMaximum;

  /// Gender question in onboarding
  ///
  /// In en, this message translates to:
  /// **'What is your gender?'**
  String get whatIsYourGender;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Gender label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Success message for profile picture upload
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated!'**
  String get profilePictureUpdated;

  /// Error prefix
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Email verification sent message
  ///
  /// In en, this message translates to:
  /// **'Verification email sent! Please check your inbox.'**
  String get verificationEmailSent;

  /// Email verified success message
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerifiedSuccessfully;

  /// Email not yet verified message
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Please check your inbox.'**
  String get emailNotVerifiedYet;

  /// Edit profile button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No user error message
  ///
  /// In en, this message translates to:
  /// **'No user logged in'**
  String get noUserLoggedIn;

  /// No profile data message
  ///
  /// In en, this message translates to:
  /// **'No profile data available'**
  String get noProfileDataAvailable;

  /// Profile incomplete banner title
  ///
  /// In en, this message translates to:
  /// **'Profile Incomplete'**
  String get profileIncomplete;

  /// Profile incomplete banner message
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to get personalized recommendations'**
  String get completeProfileMessage;

  /// Complete profile button text
  ///
  /// In en, this message translates to:
  /// **'Complete Profile Now'**
  String get completeProfileNow;

  /// Not set placeholder text
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Tooltip for verification check button
  ///
  /// In en, this message translates to:
  /// **'Check verification status'**
  String get checkVerificationStatus;

  /// Verify button text
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Turkish language option
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// Action sheet title for changing profile picture
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get changeProfilePicture;

  /// Camera option in image source picker
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Gallery option in image source picker
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Settings page title and navigation label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// App lock setting label
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// App lock setting description
  ///
  /// In en, this message translates to:
  /// **'Require PIN to unlock the app'**
  String get appLockDescription;

  /// Lock timeout setting label
  ///
  /// In en, this message translates to:
  /// **'Lock Timeout'**
  String get lockTimeout;

  /// Lock timeout immediate option
  ///
  /// In en, this message translates to:
  /// **'Immediate'**
  String get lockTimeoutImmediate;

  /// Lock timeout 30 seconds option
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get lockTimeout30s;

  /// Lock timeout 1 minute option
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get lockTimeout1min;

  /// Lock timeout 5 minutes option
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get lockTimeout5min;

  /// Lock timeout 15 minutes option
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get lockTimeout15min;

  /// Change PIN setting label
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// Change PIN setting description
  ///
  /// In en, this message translates to:
  /// **'Update your 4-digit PIN'**
  String get changePinDescription;

  /// Biometrics setting label
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// Biometrics setting description
  ///
  /// In en, this message translates to:
  /// **'Use Face ID / Touch ID'**
  String get biometricsDescription;

  /// Set PIN dialog title
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPin;

  /// Enter PIN placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// Enter 4-digit PIN placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter 4-digit PIN'**
  String get enter4DigitPin;

  /// PIN validation error
  ///
  /// In en, this message translates to:
  /// **'PIN must be 4 digits'**
  String get pinMustBe4Digits;

  /// Incorrect PIN error message
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get incorrectPin;

  /// PIN update success message
  ///
  /// In en, this message translates to:
  /// **'PIN updated'**
  String get pinUpdated;

  /// Biometric authentication reason
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock the app'**
  String get authenticateToUnlock;

  /// Lock settings section description
  ///
  /// In en, this message translates to:
  /// **'Lock the app after a period of inactivity. When enabled, you will be asked to enter your PIN or use biometrics to unlock the app.'**
  String get lockSettingsDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
