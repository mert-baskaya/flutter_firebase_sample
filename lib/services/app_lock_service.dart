import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService {
  static const _lockEnabledKey = 'app_lock_enabled';
  static const _pinKey = 'app_lock_pin';
  static const _timeoutKey = 'app_lock_timeout';
  static const _biometricEnabledKey = 'app_lock_biometric';

  static const int timeoutImmediate = 0;
  static const int timeout30s = 30;
  static const int timeout1min = 60;
  static const int timeout5min = 300;
  static const int timeout15min = 900;

  static const List<int> timeoutOptions = [
    timeoutImmediate,
    timeout30s,
    timeout1min,
    timeout5min,
    timeout15min,
  ];

  final LocalAuthentication _localAuth = LocalAuthentication();
  SharedPreferences? _prefs;
  static DateTime? _backgroundTime;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool> get isLockEnabled async {
    final p = await prefs;
    return p.getBool(_lockEnabledKey) ?? false;
  }

  Future<String?> get pin async {
    final p = await prefs;
    return p.getString(_pinKey);
  }

  Future<int> get timeoutSeconds async {
    final p = await prefs;
    return p.getInt(_timeoutKey) ?? timeoutImmediate;
  }

  Future<bool> get isBiometricEnabled async {
    final p = await prefs;
    return p.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> setLockEnabled(bool value) async {
    final p = await prefs;
    await p.setBool(_lockEnabledKey, value);
  }

  Future<void> setPin(String value) async {
    final p = await prefs;
    await p.setString(_pinKey, value);
  }

  Future<void> clearPin() async {
    final p = await prefs;
    await p.remove(_pinKey);
  }

  Future<void> setTimeoutSeconds(int value) async {
    final p = await prefs;
    await p.setInt(_timeoutKey, value);
  }

  Future<void> setBiometricEnabled(bool value) async {
    final p = await prefs;
    await p.setBool(_biometricEnabledKey, value);
  }

  Future<bool> hasPin() async {
    return (await pin) != null;
  }

  bool checkPin(String enteredPin, String storedPin) {
    return enteredPin == storedPin;
  }

  void recordBackgroundTime() {
    _backgroundTime = DateTime.now();
  }

  Future<bool> shouldLock() async {
    if (!(await isLockEnabled)) return false;
    if (!(await hasPin())) return false;

    final bgTime = _backgroundTime;
    if (bgTime == null) return false;

    final timeout = await timeoutSeconds;
    final elapsed = DateTime.now().difference(bgTime).inSeconds;

    if (timeout == timeoutImmediate) return true;
    return elapsed >= timeout;
  }

  void clearBackgroundTime() {
    _backgroundTime = null;
  }

  static void clearBackgroundTimeForAll() {
    _backgroundTime = null;
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
