import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/app_lock_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/user_profile_service.dart';
import '../services/language_service.dart';
import '../models/user_profile.dart';
import '../l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final UserProfileService _profileService = UserProfileService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;
  bool _isSendingVerification = false;

  void _showAlert(String message, {bool isSuccess = true}) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _NotificationBanner(
        message: message,
        isError: !isSuccess,
        onDismissed: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  Future<void> _showImageSourcePicker() async {
    final l10n = AppLocalizations.of(context)!;
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(l10n.changeProfilePicture),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickAndUploadImage(ImageSource.camera);
            },
            child: Text(l10n.takePhoto),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _pickAndUploadImage(ImageSource.gallery);
            },
            child: Text(l10n.chooseFromGallery),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      AppLockService.clearBackgroundTimeForAll();

      if (pickedFile == null) return;

      setState(() {
        _isUploading = true;
      });

      final File imageFile = File(pickedFile.path);
      final String downloadUrl = await _storageService.uploadProfilePicture(
        imageFile,
      );

      await _authService.updateProfilePhoto(downloadUrl);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showAlert(l10n.profilePictureUpdated);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showAlert('${l10n.error}: ${e.toString()}', isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _sendEmailVerification() async {
    setState(() {
      _isSendingVerification = true;
    });

    try {
      await _authService.sendEmailVerification();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showAlert(l10n.verificationEmailSent);
      }
    } catch (e) {
      if (mounted) {
        _showAlert(e.toString(), isSuccess: false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingVerification = false;
        });
      }
    }
  }

  Future<void> _checkEmailVerification() async {
    try {
      await _authService.reloadUser();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final user = _authService.currentUser;
        if (user?.emailVerified == true) {
          _showAlert(l10n.emailVerifiedSuccessfully);
          setState(() {});
        } else {
          _showAlert(l10n.emailNotVerifiedYet, isSuccess: false);
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showAlert('${l10n.error}: ${e.toString()}', isSuccess: false);
      }
    }
  }

  Future<void> _showEditDialog(UserProfile profile) async {
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    int age = profile.age ?? 25;
    double height = profile.height ?? 170.0;
    double weight = profile.weight ?? 70.0;
    String gender = profile.gender ?? 'Male';

    final ageController = TextEditingController(text: age.toString());
    final heightController = TextEditingController(text: height.toString());
    final weightController = TextEditingController(text: weight.toString());

    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return CupertinoAlertDialog(
              title: Text(l10n.editProfile),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: ageController,
                        placeholder: l10n.age,
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            l10n.years,
                            style: const TextStyle(
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          age = int.tryParse(value) ?? age;
                        },
                      ),
                      const SizedBox(height: 12),
                      CupertinoTextField(
                        controller: heightController,
                        placeholder: l10n.height,
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            l10n.cm,
                            style: const TextStyle(
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+[.,]?\d{0,2}'),
                          ),
                        ],
                        onChanged: (value) {
                          height =
                              double.tryParse(value.replaceAll(',', '.')) ??
                              height;
                        },
                      ),
                      const SizedBox(height: 12),
                      CupertinoTextField(
                        controller: weightController,
                        placeholder: l10n.weight,
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            l10n.kg,
                            style: const TextStyle(
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+[.,]?\d{0,2}'),
                          ),
                        ],
                        onChanged: (value) {
                          weight =
                              double.tryParse(value.replaceAll(',', '.')) ??
                              weight;
                        },
                      ),
                      const SizedBox(height: 12),
                      CupertinoSlidingSegmentedControl<String>(
                        groupValue: gender,
                        children: const {
                          'Male': Text('Male', style: TextStyle(fontSize: 14)),
                          'Female': Text(
                            'Female',
                            style: TextStyle(fontSize: 14),
                          ),
                        },
                        onValueChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              gender = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text(l10n.cancel),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  child: Text(l10n.save),
                  onPressed: () async {
                    try {
                      final updatedProfile = profile.copyWith(
                        age: age,
                        height: height,
                        weight: weight,
                        gender: gender,
                        onboardingCompleted: true,
                      );

                      await _profileService.saveUserProfile(updatedProfile);

                      if (context.mounted) {
                        Navigator.pop(context);
                        if (mounted) {
                          final l10n2 = AppLocalizations.of(this.context)!;
                          _showAlert(l10n2.profileUpdatedSuccessfully);
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        final l10n2 = AppLocalizations.of(context)!;
                        _showAlert(
                          '${l10n2.error}: ${e.toString()}',
                          isSuccess: false,
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(
      context,
      listen: false,
    );

    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(l10n.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoDialogAction(
                child: Text(l10n.english),
                onPressed: () {
                  languageService.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text(l10n.turkish),
                onPressed: () {
                  languageService.setLocale(const Locale('tr'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = _authService.currentUser;

    if (user == null) {
      return Center(child: Text(l10n.noUserLoggedIn));
    }

    return StreamBuilder<UserProfile?>(
      stream: _profileService.getUserProfileStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                '${l10n.error}: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: CupertinoColors.destructiveRed),
              ),
            ),
          );
        }

        final profile = snapshot.data;

        if (profile == null) {
          return Center(child: Text(l10n.noProfileDataAvailable));
        }

        final bool isProfileIncomplete =
            !profile.onboardingCompleted ||
            profile.age == null ||
            profile.height == null ||
            profile.weight == null ||
            profile.gender == null;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Stack(
                children: [
                  _buildAvatar(
                    photoURL: user.photoURL,
                    radius: 60,
                    iconSize: 60,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _isUploading
                        ? const CupertinoActivityIndicator()
                        : GestureDetector(
                            onTap: _showImageSourcePicker,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: CupertinoColors.systemBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.camera_fill,
                                color: CupertinoColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (user.displayName != null) ...[
                Text(
                  user.displayName!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                user.email ?? l10n.noEmail,
                style: const TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 32),
              if (isProfileIncomplete) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemOrange.color.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CupertinoColors.systemOrange.color.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_circle_fill,
                        size: 36,
                        color: CupertinoColors.systemOrange,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.profileIncomplete,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.completeProfileMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CupertinoButton.filled(
                        onPressed: () => _showEditDialog(profile),
                        child: Text(l10n.completeProfileNow),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _buildSection(
                children: [
                  _buildInfoRow(
                    icon: CupertinoIcons.gift_fill,
                    iconColor: CupertinoColors.systemBlue,
                    title: l10n.age,
                    subtitle: profile.age != null
                        ? '${profile.age} ${l10n.years}'
                        : l10n.notSet,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    icon: CupertinoIcons.arrow_up_arrow_down,
                    iconColor: CupertinoColors.systemGreen,
                    title: l10n.height,
                    subtitle: profile.height != null
                        ? '${profile.height} ${l10n.cm}'
                        : l10n.notSet,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    icon: CupertinoIcons.flame_fill,
                    iconColor: CupertinoColors.systemOrange,
                    title: l10n.weight,
                    subtitle: profile.weight != null
                        ? '${profile.weight} ${l10n.kg}'
                        : l10n.notSet,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    icon: CupertinoIcons.person_fill,
                    iconColor: CupertinoColors.systemPurple,
                    title: l10n.gender,
                    subtitle: profile.gender ?? l10n.notSet,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                onPressed: () => _showEditDialog(profile),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.pencil,
                      size: 18,
                      color: CupertinoColors.systemBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.editProfile,
                      style: const TextStyle(color: CupertinoColors.systemBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                children: [
                  _buildInfoRow(
                    icon: CupertinoIcons.mail,
                    iconColor: CupertinoColors.systemBlue,
                    title: l10n.email,
                    subtitle: user.email ?? l10n.noEmail,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    icon: user.emailVerified == true
                        ? CupertinoIcons.checkmark_seal_fill
                        : CupertinoIcons.xmark_seal_fill,
                    iconColor: user.emailVerified == true
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemOrange,
                    title: l10n.emailVerified,
                    subtitle: user.emailVerified == true ? l10n.yes : l10n.no,
                    trailing: user.emailVerified != true
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: _checkEmailVerification,
                                child: const Icon(
                                  CupertinoIcons.refresh,
                                  size: 20,
                                  color: CupertinoColors.systemBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _isSendingVerification
                                  ? const CupertinoActivityIndicator()
                                  : GestureDetector(
                                      onTap: _sendEmailVerification,
                                      child: const Text(
                                        'Verify',
                                        style: TextStyle(
                                          color: CupertinoColors.systemBlue,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                            ],
                          )
                        : null,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    icon: CupertinoIcons.calendar,
                    iconColor: CupertinoColors.systemBlue,
                    title: l10n.accountCreated,
                    subtitle:
                        user.metadata.creationTime?.toString().split('.')[0] ??
                        l10n.unknown,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    icon: CupertinoIcons.clock_fill,
                    iconColor: CupertinoColors.systemBlue,
                    title: l10n.lastSignIn,
                    subtitle:
                        user.metadata.lastSignInTime?.toString().split(
                          '.',
                        )[0] ??
                        l10n.unknown,
                  ),
                  _buildDivider(),
                  GestureDetector(
                    onTap: () => _showLanguageDialog(context),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(
                            CupertinoIcons.globe,
                            color: CupertinoColors.systemBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.language,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: CupertinoColors.label,
                                  ),
                                ),
                                Text(
                                  Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'tr'
                                      ? l10n.turkish
                                      : l10n.english,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 14),
                            child: Icon(
                              CupertinoIcons.chevron_right,
                              size: 18,
                              color: CupertinoColors.tertiaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CupertinoButton(
                onPressed: () async {
                  await _authService.signOut();
                },
                color: CupertinoColors.systemRed,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.square_arrow_right,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.signOut,
                      style: const TextStyle(color: CupertinoColors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar({
    required String? photoURL,
    required double radius,
    required double iconSize,
  }) {
    if (photoURL != null && photoURL.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoURL,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: radius * 2,
            height: radius * 2,
            decoration: const BoxDecoration(
              color: CupertinoColors.systemGrey4,
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.person_fill,
              size: iconSize,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
      );
    }
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemGrey4,
        shape: BoxShape.circle,
      ),
      child: Icon(
        CupertinoIcons.person_fill,
        size: iconSize,
        color: CupertinoColors.systemGrey,
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

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

class _NotificationBanner extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismissed;

  const _NotificationBanner({
    required this.message,
    required this.isError,
    required this.onDismissed,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _opacity = 1);
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _opacity = 0);
        Future.delayed(const Duration(milliseconds: 300), widget.onDismissed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: widget.isError
                    ? CupertinoColors.destructiveRed
                    : CupertinoColors.systemGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.message,
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
  }
}
