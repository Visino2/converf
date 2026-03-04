import 'package:flutter/material.dart';

import 'step_personal_info.dart';
import 'step_company_info.dart';
import 'step_specialization.dart';

class OnboardingContractorSignupStep extends StatefulWidget {
  final VoidCallback onSignupSubmit;
  final VoidCallback onBack;

  const OnboardingContractorSignupStep({
    super.key,
    required this.onSignupSubmit,
    required this.onBack,
  });

  @override
  State<OnboardingContractorSignupStep> createState() =>
      _OnboardingContractorSignupStepState();
}

class _OnboardingContractorSignupStepState
    extends State<OnboardingContractorSignupStep> {
  int _currentStep = 1;

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      widget.onBack();
    }
  }

  Widget _buildStepCircle(int step, bool isActive) {
    return Container(
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
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle(1, true),
          Expanded(
            child: Container(
              height: 4,
              color: _currentStep >= 2
                  ? const Color(0xFF276572)
                  : Colors.grey.shade200,
            ),
          ),
          _buildStepCircle(2, _currentStep >= 2),
          Expanded(
            child: Container(
              height: 4,
              color: _currentStep >= 3
                  ? const Color(0xFF276572)
                  : Colors.grey.shade200,
            ),
          ),
          _buildStepCircle(3, _currentStep >= 3),
        ],
      ),
    );
  }

  Widget _getCurrentStepWidget() {
    switch (_currentStep) {
      case 1:
        return ContractorPersonalInfoStep(onNext: _nextStep);
      case 2:
        return ContractorCompanyInfoStep(onNext: _nextStep);
      case 3:
        return ContractorSpecializationStep(
          onSignupSubmit: widget.onSignupSubmit,
        );
      default:
        return ContractorPersonalInfoStep(onNext: _nextStep);
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
          stops: [0.0, 0.3],
          colors: [Color(0xFF276572), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _previousStep,
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            if (_currentStep > 1) _buildProgressIndicator(),
                            if (_currentStep > 1) const SizedBox(height: 32),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _getCurrentStepWidget(),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
