import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import '../l10n/app_localizations.dart';
import '../services/app_lock_service.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onLockSettingsChanged;

  const SettingsPage({super.key, this.onLockSettingsChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppLockService _lockService = AppLockService();
  bool _lockEnabled = false;
  int _timeout = 0;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _hasPin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _lockService.isLockEnabled;
    final timeout = await _lockService.timeoutSeconds;
    final bioEnabled = await _lockService.isBiometricEnabled;
    final bioAvailable = await _lockService.isBiometricAvailable();
    final hasPin = await _lockService.hasPin();

    if (mounted) {
      setState(() {
        _lockEnabled = enabled;
        _timeout = timeout;
        _biometricEnabled = bioEnabled;
        _biometricAvailable = bioAvailable;
        _hasPin = hasPin;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLock(bool value) async {
    if (value) {
      final pin = await _showSetPinDialog();
      if (pin == null) return;
      await _lockService.setPin(pin);
      await _lockService.setLockEnabled(true);
    } else {
      await _lockService.clearPin();
      await _lockService.setLockEnabled(false);
    }
    await _loadSettings();
    widget.onLockSettingsChanged?.call();
  }

  Future<void> _changePin() async {
    final l10n = AppLocalizations.of(context)!;
    final pin = await _showSetPinDialog();
    if (pin != null) {
      await _lockService.setPin(pin);
      if (mounted) {
        _showAlert(l10n.pinUpdated);
      }
    }
  }

  Future<String?> _showSetPinDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final pinController = TextEditingController();

    return showCupertinoDialog<String>(
      context: context,
      builder: (context) {
        String pin = '';
        String? error;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return CupertinoAlertDialog(
              title: Text(_hasPin ? l10n.changePin : l10n.setPin),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: pinController,
                    placeholder: l10n.enter4DigitPin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    onChanged: (value) {
                      pin = value;
                    },
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: const TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text(l10n.cancel),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  child: Text(l10n.save),
                  onPressed: () {
                    if (pin.length != 4) {
                      setDialogState(() {
                        error = l10n.pinMustBe4Digits;
                      });
                      return;
                    }
                    Navigator.pop(context, pin);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final success = await _lockService.authenticateWithBiometrics();
      if (!success) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) {
              final l10n = AppLocalizations.of(ctx)!;
              return CupertinoAlertDialog(
                title: Text(l10n.biometricUnavailable),
                content: Text(
                  l10n.biometricSetupInstructions(_biometricTypeName()),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text(l10n.ok),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              );
            },
          );
        }
        return;
      }
    }
    await _lockService.setBiometricEnabled(value);
    setState(() => _biometricEnabled = value);
    widget.onLockSettingsChanged?.call();
  }

  Future<void> _showTimeoutPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showCupertinoModalPopup<int>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(l10n.lockTimeout),
        actions: [
          for (final option in AppLockService.timeoutOptions)
            CupertinoActionSheetAction(
              isDefaultAction: option == _timeout,
              onPressed: () => Navigator.pop(context, option),
              child: Text(_timeoutLabel(option)),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
    if (selected != null) {
      await _lockService.setTimeoutSeconds(selected);
      setState(() => _timeout = selected);
      widget.onLockSettingsChanged?.call();
    }
  }

  String _timeoutLabel(int seconds) {
    final l10n = AppLocalizations.of(context)!;
    switch (seconds) {
      case 0:
        return l10n.lockTimeoutImmediate;
      case 30:
        return l10n.lockTimeout30s;
      case 60:
        return l10n.lockTimeout1min;
      case 300:
        return l10n.lockTimeout5min;
      case 900:
        return l10n.lockTimeout15min;
      default:
        return '$seconds ${l10n.seconds}';
    }
  }

  String _biometricTypeName() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Fingerprint';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return 'Face ID / Touch ID';
      default:
        return 'Biometrics';
    }
  }

  void _showAlert(String message) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(l10n.settings)),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildSection(
              children: [
                _buildSwitchRow(
                  icon: CupertinoIcons.lock_fill,
                  iconColor: CupertinoColors.systemBlue,
                  title: l10n.appLock,
                  subtitle: l10n.appLockDescription,
                  value: _lockEnabled,
                  onChanged: _toggleLock,
                ),
              ],
            ),
            if (_lockEnabled) ...[
              const SizedBox(height: 24),
              _buildSection(
                children: [
                  _buildTapRow(
                    icon: CupertinoIcons.timer,
                    iconColor: CupertinoColors.systemOrange,
                    title: l10n.lockTimeout,
                    subtitle: _timeoutLabel(_timeout),
                    onTap: _showTimeoutPicker,
                  ),
                  _buildDivider(),
                  _buildTapRow(
                    icon: CupertinoIcons.lock_fill,
                    iconColor: CupertinoColors.systemPurple,
                    title: l10n.changePin,
                    subtitle: l10n.changePinDescription,
                    onTap: _changePin,
                  ),
                  _buildDivider(),
                  _buildSwitchRow(
                    icon: CupertinoIcons.hand_raised_fill,
                    iconColor: CupertinoColors.systemGreen,
                    title: l10n.biometrics,
                    subtitle: _biometricAvailable
                        ? l10n.useBiometric(_biometricTypeName())
                        : l10n.biometricsNotAvailable,
                    value: _biometricEnabled,
                    onChanged: _biometricAvailable ? _toggleBiometric : null,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.lockSettingsDescription,
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 54),
      height: 0.5,
      color: CupertinoColors.separator,
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    final enabled = onChanged != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: enabled
                        ? CupertinoColors.label
                        : CupertinoColors.systemGrey,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: enabled
                        ? CupertinoColors.secondaryLabel
                        : CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTapRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.label,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: CupertinoColors.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}
