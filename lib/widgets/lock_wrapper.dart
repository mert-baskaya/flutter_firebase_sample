import 'package:flutter/cupertino.dart';
import '../services/app_lock_service.dart';
import '../pages/lock_screen.dart';

class LockWrapper extends StatefulWidget {
  final Widget child;

  const LockWrapper({super.key, required this.child});

  @override
  State<LockWrapper> createState() => _LockWrapperState();
}

class _LockWrapperState extends State<LockWrapper> with WidgetsBindingObserver {
  final AppLockService _lockService = AppLockService();
  bool _isLocked = false;
  bool _initialized = false;
  bool _pendingResumeCheck = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkInitialLock() async {
    final enabled = await _lockService.isLockEnabled;
    final hasPin = await _lockService.hasPin();
    if (enabled && hasPin) {
      if (mounted) {
        setState(() => _isLocked = true);
      }
    }
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lockService.recordBackgroundTime();
    } else if (state == AppLifecycleState.resumed) {
      if (!_pendingResumeCheck) {
        _pendingResumeCheck = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          _pendingResumeCheck = false;
          _checkIfShouldLock();
        });
      }
    }
  }

  Future<void> _checkIfShouldLock() async {
    if (await _lockService.shouldLock()) {
      if (mounted) {
        setState(() => _isLocked = true);
      }
    }
  }

  void _onUnlocked() {
    _lockService.clearBackgroundTime();
    setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    if (_isLocked) {
      return LockScreen(onUnlocked: _onUnlocked);
    }

    return widget.child;
  }
}
