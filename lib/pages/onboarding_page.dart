import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile.dart';
import '../l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();
  final UserProfileService _profileService = UserProfileService();

  int _currentPage = 0;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  int? _age;
  double? _height;
  double? _weight;
  String _gender = 'Male';

  String? _ageError;
  String? _heightError;
  String? _weightError;

  final FocusNode _ageFocusNode = FocusNode();
  final FocusNode _heightFocusNode = FocusNode();
  final FocusNode _weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ageFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageFocusNode.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  bool _validateAge() {
    final value = _ageController.text.trim();
    if (value.isEmpty) {
      _ageError = AppLocalizations.of(context)!.pleaseEnterAge;
      setState(() {});
      return false;
    }
    final age = int.tryParse(value);
    if (age == null) {
      _ageError = AppLocalizations.of(context)!.pleaseEnterValidNumber;
      setState(() {});
      return false;
    }
    if (age < 18) {
      _ageError = AppLocalizations.of(context)!.mustBeAtLeast18;
      setState(() {});
      return false;
    }
    if (age > 120) {
      _ageError = AppLocalizations.of(context)!.pleaseEnterValidAge;
      setState(() {});
      return false;
    }
    _age = age;
    _ageError = null;
    setState(() {});
    return true;
  }

  bool _validateHeight() {
    final value = _heightController.text.trim();
    if (value.isEmpty) {
      _heightError = AppLocalizations.of(context)!.pleaseEnterHeight;
      setState(() {});
      return false;
    }
    final height = double.tryParse(value);
    if (height == null) {
      _heightError = AppLocalizations.of(context)!.pleaseEnterValidNumber;
      setState(() {});
      return false;
    }
    if (height < 50) {
      _heightError = AppLocalizations.of(context)!.heightMinimum;
      setState(() {});
      return false;
    }
    if (height > 300) {
      _heightError = AppLocalizations.of(context)!.heightMaximum;
      setState(() {});
      return false;
    }
    _height = height;
    _heightError = null;
    setState(() {});
    return true;
  }

  bool _validateWeight() {
    final value = _weightController.text.trim();
    if (value.isEmpty) {
      _weightError = AppLocalizations.of(context)!.pleaseEnterWeight;
      setState(() {});
      return false;
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      _weightError = AppLocalizations.of(context)!.pleaseEnterValidNumber;
      setState(() {});
      return false;
    }
    if (weight < 20) {
      _weightError = AppLocalizations.of(context)!.weightMinimum;
      setState(() {});
      return false;
    }
    if (weight > 500) {
      _weightError = AppLocalizations.of(context)!.weightMaximum;
      setState(() {});
      return false;
    }
    _weight = weight;
    _weightError = null;
    setState(() {});
    return true;
  }

  void _nextPage() {
    if (_currentPage < 3) {
      bool isValid = false;
      switch (_currentPage) {
        case 0:
          isValid = _validateAge();
          break;
        case 1:
          isValid = _validateHeight();
          break;
        case 2:
          isValid = _validateWeight();
          break;
        case 3:
          isValid = true;
          break;
      }

      if (isValid) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = UserProfile(
        uid: user.uid,
        age: _age!,
        height: _height!,
        weight: _weight!,
        gender: _gender,
        onboardingCompleted: true,
      );

      await _profileService.saveUserProfile(profile);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _skipOnboarding() async {
    final user = _authService.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = UserProfile(uid: user.uid, onboardingCompleted: false);
      await _profileService.saveUserProfile(profile);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.completeYourProfile),
        trailing: GestureDetector(
          onTap: _isLoading ? null : _skipOnboarding,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              l10n.skip,
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemBlue,
              ),
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: List.generate(4, (index) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: index == 0 ? 0 : 2,
                            right: index == 3 ? 0 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: index <= _currentPage
                                ? CupertinoColors.systemBlue
                                : const Color(0x00000000),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    switch (page) {
                      case 0:
                        _ageFocusNode.requestFocus();
                        break;
                      case 1:
                        _heightFocusNode.requestFocus();
                        break;
                      case 2:
                        _weightFocusNode.requestFocus();
                        break;
                    }
                  });
                },
                children: [
                  _buildAgePage(),
                  _buildHeightPage(),
                  _buildWeightPage(),
                  _buildGenderPage(),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: CupertinoColors.systemRed,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: CupertinoButton(
                        onPressed: _isLoading ? null : _previousPage,
                        child: Text(l10n.back),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: CupertinoButton.filled(
                      onPressed: _isLoading ? null : _nextPage,
                      child: _isLoading
                          ? const CupertinoActivityIndicator()
                          : Text(_currentPage < 3 ? l10n.next : l10n.complete),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgePage() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.gift_fill,
            size: 64,
            color: CupertinoColors.systemBlue,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.howOldAreYou,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CupertinoTextField(
            focusNode: _ageFocusNode,
            controller: _ageController,
            placeholder: l10n.enterYourAge,
            suffix: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                l10n.years,
                style: const TextStyle(color: CupertinoColors.secondaryLabel),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
            placeholderStyle: const TextStyle(
              color: CupertinoColors.placeholderText,
              fontSize: 18,
            ),
            onChanged: (_) {
              if (_ageError != null) {
                setState(() {
                  _ageError = null;
                });
              }
            },
          ),
          if (_ageError != null) ...[
            const SizedBox(height: 8),
            Text(
              _ageError!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeightPage() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.arrow_up_arrow_down,
            size: 64,
            color: CupertinoColors.systemGreen,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.whatIsYourHeight,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CupertinoTextField(
            focusNode: _heightFocusNode,
            controller: _heightController,
            placeholder: l10n.enterYourHeight,
            suffix: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                l10n.cm,
                style: const TextStyle(color: CupertinoColors.secondaryLabel),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
            placeholderStyle: const TextStyle(
              color: CupertinoColors.placeholderText,
              fontSize: 18,
            ),
            onChanged: (_) {
              if (_heightError != null) {
                setState(() {
                  _heightError = null;
                });
              }
            },
          ),
          if (_heightError != null) ...[
            const SizedBox(height: 8),
            Text(
              _heightError!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeightPage() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.flame_fill,
            size: 64,
            color: CupertinoColors.systemOrange,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.whatIsYourWeight,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CupertinoTextField(
            focusNode: _weightFocusNode,
            controller: _weightController,
            placeholder: l10n.enterYourWeight,
            suffix: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                l10n.kg,
                style: const TextStyle(color: CupertinoColors.secondaryLabel),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
            placeholderStyle: const TextStyle(
              color: CupertinoColors.placeholderText,
              fontSize: 18,
            ),
            onChanged: (_) {
              if (_weightError != null) {
                setState(() {
                  _weightError = null;
                });
              }
            },
          ),
          if (_weightError != null) ...[
            const SizedBox(height: 8),
            Text(
              _weightError!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenderPage() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.person_fill,
            size: 64,
            color: CupertinoColors.systemPurple,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.whatIsYourGender,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.secondarySystemBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _gender = 'Male';
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.person_fill,
                          color: CupertinoColors.systemBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          l10n.male,
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.label,
                          ),
                        ),
                        const Spacer(),
                        if (_gender == 'Male')
                          const Icon(
                            CupertinoIcons.checkmark_alt,
                            color: CupertinoColors.systemBlue,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 54),
                  height: 0.5,
                  color: CupertinoColors.separator,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _gender = 'Female';
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.person_fill,
                          color: CupertinoColors.systemPink,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          l10n.female,
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.label,
                          ),
                        ),
                        const Spacer(),
                        if (_gender == 'Female')
                          const Icon(
                            CupertinoIcons.checkmark_alt,
                            color: CupertinoColors.systemBlue,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
