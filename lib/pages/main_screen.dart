import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import 'diet_page.dart';
import 'exercise_page.dart';
import 'progress_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _lockSettingsVersion = 0;

  void _onLockSettingsChanged() {
    setState(() {
      _lockSettingsVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.userChanges,
      builder: (context, snapshot) {
        return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.flame_fill),
                activeIcon: Icon(CupertinoIcons.flame_fill),
                label: l10n.diet,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.heart_fill),
                activeIcon: Icon(CupertinoIcons.heart_fill),
                label: l10n.exercise,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_bar_fill),
                activeIcon: Icon(CupertinoIcons.chart_bar_fill),
                label: l10n.progress,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_fill),
                activeIcon: Icon(CupertinoIcons.person_fill),
                label: l10n.profile,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                activeIcon: Icon(CupertinoIcons.settings),
                label: 'Settings',
              ),
            ],
            activeColor: CupertinoColors.systemBlue,
            inactiveColor: CupertinoColors.systemGrey,
          ),
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return CupertinoTabView(
                  builder: (_) => const _TabScaffold(child: DietPage()),
                );
              case 1:
                return CupertinoTabView(
                  builder: (_) => const _TabScaffold(child: ExercisePage()),
                );
              case 2:
                return CupertinoTabView(
                  builder: (_) => const _TabScaffold(child: ProgressPage()),
                );
              case 3:
                return CupertinoTabView(
                  builder: (_) => const _TabScaffold(child: ProfilePage()),
                );
              case 4:
                return CupertinoTabView(
                  builder: (_) => SettingsPage(
                    key: ValueKey('settings_$_lockSettingsVersion'),
                    onLockSettingsChanged: _onLockSettingsChanged,
                  ),
                );
              default:
                return CupertinoTabView(
                  builder: (_) => const _TabScaffold(child: DietPage()),
                );
            }
          },
        );
      },
    );
  }
}

class _TabScaffold extends StatelessWidget {
  final Widget child;
  const _TabScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: SafeArea(child: child));
  }
}
