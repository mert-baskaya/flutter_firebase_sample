import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/user_profile_service.dart';
import 'services/language_service.dart';
import 'pages/login_page.dart';
import 'pages/main_screen.dart';
import 'pages/onboarding_page.dart';
import 'widgets/lock_wrapper.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return CupertinoApp(
          title: 'Fitness Tracker',
          theme: const CupertinoThemeData(
            primaryColor: CupertinoColors.systemBlue,
            brightness: Brightness.light,
            barBackgroundColor: CupertinoColors.systemBackground,
            scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
            textTheme: CupertinoTextThemeData(
              primaryColor: CupertinoColors.label,
            ),
          ),
          locale: languageService.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('tr')],
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final UserProfileService profileService = UserProfileService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data;
          return StreamBuilder(
            stream: profileService.getUserProfileStream(user!.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const CupertinoPageScaffold(
                  child: Center(child: CupertinoActivityIndicator()),
                );
              }

              if (profileSnapshot.hasError) {
                return CupertinoPageScaffold(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        '${profileSnapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CupertinoColors.destructiveRed,
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (profileSnapshot.hasData) {
                return LockWrapper(child: const MainScreen());
              }

              return const OnboardingPage();
            },
          );
        }

        return const LoginPage();
      },
    );
  }
}
