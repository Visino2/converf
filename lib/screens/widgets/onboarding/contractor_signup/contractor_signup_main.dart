import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:converf/core/ui/app_colors.dart';

import 'step_personal_info.dart';
import 'step_company_info.dart';
import 'step_specialization.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/auth/providers/email_verification_provider.dart';
import '../../../../features/auth/repositories/auth_repository.dart';
import '../../../../features/auth/models/contractor_register_request.dart';
import '../../../../features/auth/models/email_verification_status.dart';
import '../../../../features/auth/utils/auth_flow.dart';

class OnboardingContractorSignupStep extends ConsumerStatefulWidget {
  final VoidCallback onSignupSubmit;
  final VoidCallback onBack;

  const OnboardingContractorSignupStep({
    super.key,
    required this.onSignupSubmit,
    required this.onBack,
  });

  @override
  ConsumerState<OnboardingContractorSignupStep> createState() =>
      _OnboardingContractorSignupStepState();
}

class _OnboardingContractorSignupStepState
    extends ConsumerState<OnboardingContractorSignupStep> {
  int _currentStep = 1;
  String? _emailBackendError;
  bool _isCheckingEmail = false;

  // Controllers for all steps
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _tinController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State for all steps
  String? _selectedCountry = 'Nigeria';
  String? _yearsInBusiness;
  final Map<String, bool> _specializations = {
    'residential': false,
    'infrastructure': false,
    'commercial': false,
    'industrial': false,
    'roadway': false,
    'renovation': false,
  };
  bool _termsAgreed = false;
  bool _infoAccurate = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _registrationNumberController.dispose();
    _licenseNumberController.dispose();
    _addressController.dispose();
    _tinController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep == 1) {
      setState(() {
        _isCheckingEmail = true;
        _emailBackendError = null;
      });

      try {
        final email = _emailController.text.trim();
        final repository = ref.read(authRepositoryProvider);
        final exists = await repository.checkEmailExists(email);

        if (!mounted) return;

        if (exists) {
          setState(() {
            _isCheckingEmail = false;
            _emailBackendError = 'This email is already registered';
          });
          return; // Stop here, do not advance
        }
      } catch (e) {
        // Fallback: if checking fails for any other reason, just proceed and let step 3 catch it.
      } finally {
        if (mounted) {
          setState(() {
            _isCheckingEmail = false;
          });
        }
      }
    }

    if (!mounted) return;

    setState(() {
      _currentStep++;
    });
  }

  void _goToStep(int step) {
    if (step < _currentStep) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  Future<void> _handleSignup() async {
    // Validation
    if (!_termsAgreed || !_infoAccurate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to all terms and conditions'),
        ),
      );
      return;
    }

    final selectedSpecs = _specializations.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedSpecs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one specialization'),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    // Convert "3-5 Years" to int 5 as per request example
    int years = 0;
    if (_yearsInBusiness != null) {
      if (_yearsInBusiness!.contains('1-2')) {
        years = 2;
      } else if (_yearsInBusiness!.contains('3-5')) {
        years = 5;
      } else if (_yearsInBusiness!.contains('5-10')) {
        years = 10;
      } else if (_yearsInBusiness!.contains('10+')) {
        years = 15;
      }
    }

    final request = ContractorRegisterRequest(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      country: _selectedCountry ?? '',
      companyName: _companyNameController.text,
      businessRegistrationNumber: _registrationNumberController.text,
      yearsInBusiness: years,
      licenseNumber: _licenseNumberController.text,
      constructionSpecialisations: selectedSpecs,
      businessAddress: _addressController.text,
      taxIdentificationNumber: _tinController.text,
      agreedToTerms: _termsAgreed,
      confirmedInformationAccuracy: _infoAccurate,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    await ref.read(authProvider.notifier).registerContractor(request);

    // Add delay to allow authProvider state to propagate before reading it
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      final authState = ref.read(authProvider);
      bool shouldAttemptVerify = false;
      if (authState.hasError) {
        String error = authState.error.toString();
        if (error.contains('Exception:')) {
          error = error.replaceAll('Exception: ', '');
        }

        // Specifically check for "already registered" or "email taken"
        if (error.toLowerCase().contains('email') &&
            (error.toLowerCase().contains('taken') ||
                error.toLowerCase().contains('registered') ||
                error.toLowerCase().contains('exists'))) {
          setState(
            () => _emailBackendError = 'This email is already registered',
          );
          shouldAttemptVerify = _looksLikeUnverified(error);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (authState.value?.status == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.value?.message ?? 'Registration failed'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        shouldAttemptVerify = _looksLikeUnverified(
          authState.value?.message ?? '',
        );
      } else {
        if (!mounted) {
          return;
        }

        // Smooth transition to onboarding welcome step
        widget.onSignupSubmit();
        return;
      }

      if (shouldAttemptVerify) {
        await _tryLoginAndNavigateToVerify();
      }
    }
  }

  bool _looksLikeUnverified(String text) {
    final normalized = text.toLowerCase();
    return normalized.contains('not verified') ||
        normalized.contains('verify') ||
        normalized.contains('unverified');
  }

  Future<void> _tryLoginAndNavigateToVerify() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      return;
    }

    await ref.read(authProvider.notifier).login(email, password);

    // Add delay to allow authProvider state to propagate before reading it
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) {
      return;
    }
    final loginState = ref.read(authProvider);
    if (loginState.hasError || loginState.value?.data == null) {
      return;
    }

    var status = verificationStatusFromAuthResponse(loginState.value);
    if (!status.isKnown) {
      status = await ref.read(emailVerificationStatusProvider.future);
    }
    if (!mounted) {
      return;
    }

    if (status == EmailVerificationStatus.verified) {
      context.go('/welcome');
    } else {
      context.go(
        verifyEmailLocation(
          email: loginState.value?.data?.user['email']?.toString() ?? email,
          autoResend: true,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account found but not verified. Check your email to continue.',
          ),
        ),
      );
    }
  }

  Widget _buildStepCircle(int step, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? const Color(0xFF276572) : Colors.white,
          border: Border.all(
            color: isActive ? const Color(0xFF276572) : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          step.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade500,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle(1, true, onTap: () => _goToStep(1)),
          Expanded(
            child: Container(
              height: 4,
              color: _currentStep >= 2
                  ? const Color(0xFF276572)
                  : Colors.grey.shade200,
            ),
          ),
          _buildStepCircle(
            2,
            _currentStep >= 2,
            onTap: _currentStep > 2 ? () => _goToStep(2) : null,
          ),
          Expanded(
            child: Container(
              height: 4,
              color: _currentStep >= 3
                  ? const Color(0xFF276572)
                  : Colors.grey.shade200,
            ),
          ),
          _buildStepCircle(3, _currentStep >= 3, onTap: null),
        ],
      ),
    );
  }

  Widget _getCurrentStepWidget() {
    final authState = ref.watch(authProvider);

    switch (_currentStep) {
      case 1:
        return ContractorPersonalInfoStep(
          onNext: _nextStep,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          emailController: _emailController,
          selectedCountry: _selectedCountry,
          onCountrySelected: (c) => setState(() => _selectedCountry = c),
          emailBackendError: _emailBackendError,
          isCheckingEmail: _isCheckingEmail,
          onEmailChanged: () {
            if (_emailBackendError != null) {
              setState(() => _emailBackendError = null);
            }
          },
        );
      case 2:
        return ContractorCompanyInfoStep(
          onNext: _nextStep,
          companyNameController: _companyNameController,
          registrationNumberController: _registrationNumberController,
          licenseNumberController: _licenseNumberController,
          yearsInBusiness: _yearsInBusiness,
          onYearsSelected: (y) => setState(() => _yearsInBusiness = y),
        );
      case 3:
        return ContractorSpecializationStep(
          onSignupSubmit: _handleSignup,
          addressController: _addressController,
          tinController: _tinController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          specializations: _specializations,
          onSpecializationChanged: (key, value) =>
              setState(() => _specializations[key] = value),
          termsAgreed: _termsAgreed,
          onTermsChanged: (v) => setState(() => _termsAgreed = v),
          infoAccurate: _infoAccurate,
          onInfoAccurateChanged: (v) => setState(() => _infoAccurate = v),
          isLoading: authState.isLoading,
        );
      default:
        return ContractorPersonalInfoStep(
          onNext: _nextStep,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          emailController: _emailController,
          selectedCountry: _selectedCountry,
          onCountrySelected: (c) => setState(() => _selectedCountry = c),
          emailBackendError: _emailBackendError,
          isCheckingEmail: _isCheckingEmail,
          onEmailChanged: () {
            if (_emailBackendError != null) {
              setState(() => _emailBackendError = null);
            }
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('contractor_signup_main'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.45],
          colors: [AppColors.authShellTop, Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _currentStep < 3
                      ? ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(),
                                _buildProgressIndicator(),
                                const SizedBox(height: 32),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: _getCurrentStepWidget(),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            _buildProgressIndicator(),
                            const SizedBox(height: 32),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _getCurrentStepWidget(),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
