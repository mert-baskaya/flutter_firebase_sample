import 'package:flutter/cupertino.dart';
import '../services/app_lock_service.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final AppLockService _lockService = AppLockService();
  final List<int> _enteredPin = [];
  String? _error;
  bool _biometricAttempted = false;

  static const int _pinLength = 4;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    if (_biometricAttempted) return;
    _biometricAttempted = true;

    final enabled = await _lockService.isBiometricEnabled;
    if (!enabled) return;

    final available = await _lockService.isBiometricAvailable();
    if (!available) return;

    final success = await _lockService.authenticateWithBiometrics();
    if (success && mounted) {
      widget.onUnlocked();
    }
  }

  void _onDigitPressed(int digit) {
    if (_enteredPin.length >= _pinLength) return;
    setState(() {
      _enteredPin.add(digit);
      _error = null;
    });
    if (_enteredPin.length == _pinLength) {
      _verifyPin();
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin.removeLast();
      _error = null;
    });
  }

  Future<void> _verifyPin() async {
    final entered = _enteredPin.join();
    final stored = await _lockService.pin;
    if (stored == null) return;

    if (_lockService.checkPin(entered, stored)) {
      if (mounted) {
        widget.onUnlocked();
      }
    } else {
      setState(() {
        _enteredPin.clear();
        _error = 'Incorrect PIN';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            const Icon(
              CupertinoIcons.lock_fill,
              size: 48,
              color: CupertinoColors.systemBlue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter PIN',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            _buildPinDots(),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                  color: CupertinoColors.destructiveRed,
                  fontSize: 14,
                ),
              ),
            ],
            const Spacer(flex: 1),
            _buildNumpad(),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < _enteredPin.length
                ? CupertinoColors.activeBlue
                : CupertinoColors.systemGrey5,
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _buildNumpadRow([1, 2, 3]),
          const SizedBox(height: 12),
          _buildNumpadRow([4, 5, 6]),
          const SizedBox(height: 12),
          _buildNumpadRow([7, 8, 9]),
          const SizedBox(height: 12),
          _buildNumpadRow([-1, 0, -2]),
        ],
      ),
    );
  }

  Widget _buildNumpadRow(List<int> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key == -1) {
          return const SizedBox(width: 72, height: 72);
        }
        if (key == -2) {
          return _NumpadButton(
            onPressed: _onDeletePressed,
            child: const Icon(
              CupertinoIcons.delete_left,
              size: 28,
              color: CupertinoColors.label,
            ),
          );
        }
        return _NumpadButton(
          onPressed: () => _onDigitPressed(key),
          child: Text(
            '$key',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.label,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _NumpadButton({required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      minimumSize: const Size(72, 72),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CupertinoColors.systemGrey5,
        ),
        child: Center(child: child),
      ),
    );
  }
}
