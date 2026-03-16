import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/projects/providers/project_providers.dart';
import '../../../../features/projects/models/project_payloads.dart';
import '../../../../features/projects/models/project.dart';

class NewProjectModal extends ConsumerStatefulWidget {
  final Project? initialProject;
  const NewProjectModal({super.key, this.initialProject});

  @override
  ConsumerState<NewProjectModal> createState() => _NewProjectModalState();
}

class _NewProjectModalState extends ConsumerState<NewProjectModal> {
  int _currentStep = 0;
  String? _projectId;

  // Step 1 State
  int? _selectedIndex;
  final List<Map<String, String>> _projectTypes = [
    {'title': 'Residential\nConstruction', 'icon': 'assets/images/home-1.svg', 'value': 'residential'},
    {
      'title': 'Commercial\nConstruction',
      'icon': 'assets/images/Buildings.svg',
      'value': 'commercial',
    },
    {'title': 'Roadway\nConstruction', 'icon': 'assets/images/truck.svg', 'value': 'roadway'},
    {'title': 'Infrastructure\nProjects', 'icon': 'assets/images/crane.svg', 'value': 'infrastructure'},
  ];

  // Step 2 State
  final _projectNameController = TextEditingController();
  final _projectDescController = TextEditingController();
  String? _selectedSubType;
  final _referenceIdController = TextEditingController();
  final Map<String, List<String>> _subTypeOptions = {
    'residential': ['Villa', 'Apartment', 'Duplex', 'Terrace', 'Bungalow'],
    'commercial': ['Office', 'Retail', 'Hospitality', 'Industrial', 'Medical'],
    'roadway': ['Highway', 'Urban Road', 'Bridge', 'Interchange'],
    'infrastructure': ['Water Supply', 'Power Plant', 'Telecommunications', 'Dam'],
  };

  // Step 3 State
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;
  final _addressController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPriority = 'normal';

  // Location Data Map
  final Map<String, Map<String, List<String>>> _locationData = {
    'Nigeria': {
      'Lagos': ['Lekki', 'Ikeja', 'Victoria Island', 'Ikoyi'],
      'Abuja': ['Maitama', 'Wuse', 'Garki', 'Asokoro'],
      'Kano': ['Kano City', 'Tarauni', 'Nassarawa'],
      'Rivers': ['Port Harcourt', 'Obio-Akpor', 'Okrika'],
    },
    'Kenya': {
      'Nairobi': ['Westlands', 'Kilimani', 'Karen'],
      'Mombasa': ['Nyali', 'Mtwapa', 'Diani'],
    },
    'Ghana': {
      'Greater Accra': ['Accra', 'Tema', 'Cantonments'],
      'Ashanti': ['Kumasi', 'Obuasi'],
    },
    'South Africa': {
      'Gauteng': ['Johannesburg', 'Pretoria', 'Sandton'],
      'Western Cape': ['Cape Town', 'Stellenbosch'],
    },
  };

  // Step 4 State
  String _selectedCurrency = '₦';
  final _budgetController = TextEditingController();
  String? _assignmentType;
  DateTime? _biddingDeadline;

  // Step 5 State
  bool _confirmInfo = false;
  bool _agreeTerms = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialProject != null) {
      final p = widget.initialProject!;
      _projectId = p.id;
      _currentStep = (p.currentStep - 1).clamp(0, 4);
      
      // Step 1
      _selectedIndex = _projectTypes.indexWhere((t) => t['value'] == p.constructionType);
      if (_selectedIndex == -1) _selectedIndex = null;

      // Step 2
      _projectNameController.text = p.title;
      _projectDescController.text = p.description;
      _selectedSubType = p.constructionSubType;

      // Step 3
      _selectedCountry = p.country.isNotEmpty ? p.country : null;
      _selectedState = p.state.isNotEmpty ? p.state : null;
      _selectedCity = p.city.isNotEmpty ? p.city : null;
      _addressController.text = p.location;
      
      try {
        if (p.startDate.isNotEmpty) _startDate = DateTime.parse(p.startDate);
        if (p.endDate.isNotEmpty) _endDate = DateTime.parse(p.endDate);
      } catch (_) {}
      
      _selectedPriority = p.urgencyLevel.toLowerCase();

      // Step 4
      _selectedCurrency = p.currency == 'NGN' ? '₦' : (p.currency == 'USD' ? '\$' : '₦');
      _budgetController.text = p.budget;
      _assignmentType = p.assignmentMethod.isNotEmpty ? p.assignmentMethod : null;
      
      try {
        if (p.biddingDeadline != null) _biddingDeadline = DateTime.parse(p.biddingDeadline!);
      } catch (_) {}
    }
  }

  bool _isStepValid() {
    if (_currentStep == 0) return _selectedIndex != null;
    if (_currentStep == 1) {
      return _projectNameController.text.isNotEmpty &&
          _projectDescController.text.isNotEmpty &&
          _selectedSubType != null;
    }
    if (_currentStep == 2) {
      return _selectedCountry != null &&
          _selectedState != null &&
          _selectedCity != null &&
          _addressController.text.isNotEmpty &&
          _startDate != null &&
          _endDate != null &&
          _endDate!.isAfter(_startDate!);
    }
    if (_currentStep == 3) {
      if (_budgetController.text.isEmpty) return false;
      if (_assignmentType == null) return false;
      if (_assignmentType == 'tender') {
        if (_biddingDeadline == null) return false;
        if (_startDate != null && !_biddingDeadline!.isBefore(_startDate!)) return false;
      }
      return true;
    }
    if (_currentStep == 4) {
      return _confirmInfo && _agreeTerms;
    }
    return false;
  }

  Future<void> _nextStep() async {
    if (!_isStepValid()) return;

    try {
      if (_currentStep == 0) {
        // Selection step - just move forward locally
        setState(() => _currentStep++);
      } else if (_currentStep == 1) {
        if (_projectId == null) {
          // First time persistence (POST)
          final payload = StartWizardPayload(
            constructionType: _projectTypes[_selectedIndex!]['value']!,
            title: _projectNameController.text,
            description: _projectDescController.text,
            constructionSubType: _selectedSubType,
          );
          final response = await ref.read(projectWizardProvider.notifier).startWizard(payload);
          if (response.project != null) {
            _projectId = response.project!.id;
          } else {
            throw Exception('Failed to initialize project on server. Please try again.');
          }
        } else {
          // Update existing session (PATCH)
          final payload = UpdateBasicInfoPayload(
            wizardStep: 2, // Map to backend Step 2
            title: _projectNameController.text,
            description: _projectDescController.text,
            constructionSubType: _selectedSubType,
          );
          await ref.read(projectWizardProvider.notifier).updateBasicInfo(_projectId!, payload);
        }
        setState(() => _currentStep++);
      } else if (_currentStep == 2) {
        if (_projectId == null) {
          throw Exception('Project session lost. Please restart.');
        }
        // Update Location API
        final payload = UpdateLocationPayload(
          wizardStep: 3, // Map to backend Step 3
          location: _addressController.text,
          city: _selectedCity!,
          state: _selectedState!,
          country: _selectedCountry!,
        );
        await ref.read(projectWizardProvider.notifier).updateLocation(_projectId!, payload);
        setState(() => _currentStep++);
      } else if (_currentStep == 3) {
        if (_projectId == null) {
          throw Exception('Project session lost. Please restart.');
        }
        // Update Timeline & Budget API
        final amountStr = _budgetController.text.trim().replaceAll(',', '').replaceAll('₦', '').replaceAll('\$', '');
        final budget = num.tryParse(amountStr) ?? 0;
        
        final payload = UpdateTimelineBudgetPayload(
          wizardStep: 4, // Map to backend Step 4
          startDate: _startDate!.toIso8601String(),
          endDate: _endDate!.toIso8601String(),
          budget: budget,
          currency: _selectedCurrency == '₦' ? 'NGN' : 'USD',
          urgencyLevel: _selectedPriority,
          assignmentMethod: _assignmentType!,
          biddingDeadline: _biddingDeadline?.toIso8601String(),
        );
        await ref.read(projectWizardProvider.notifier).updateTimelineBudget(_projectId!, payload);
        setState(() => _currentStep++);
      } else if (_currentStep == 4) {
        if (_projectId == null) {
          throw Exception('Project session lost. Please restart.');
        }
        // Confirm Project API
        try {
          final payload = ConfirmProjectPayload(
            wizardStep: 5, // Map to backend Step 5
            confirm: _confirmInfo && _agreeTerms,
          );
          await ref.read(projectWizardProvider.notifier).confirmProject(_projectId!, payload);
        } catch (confirmError) {
          debugPrint('Confirm step warning: $confirmError');
        }
        setState(() => _isSuccess = true);
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceAll('Exception: ', '');
      }
      if (errorMessage.contains('Failed host lookup')) {
        errorMessage = 'Network Error: Unable to reach the server. Please check your internet connection.';
      } else if (errorMessage.contains('timeout')) {
        errorMessage = 'Connection Timeout: The server is taking too long to respond. Please try again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = ref.watch(projectWizardProvider);
    final isLoading = wizardState.isLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (_isSuccess)
                    Expanded(child: SingleChildScrollView(child: _buildSuccessScreen()))
                  else ...[
                    // Fixed Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Create New Project',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'This will auto save',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF3F4F6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Progress Bar
                          if (_currentStep > 0) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Step $_currentStep of 4',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F973D),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  flex: _currentStep,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A8090),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(4),
                                        bottomLeft: const Radius.circular(4),
                                        topRight: _currentStep == 4
                                            ? const Radius.circular(4)
                                            : Radius.zero,
                                        bottomRight: _currentStep == 4
                                            ? const Radius.circular(4)
                                            : Radius.zero,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_currentStep < 4)
                                  Expanded(
                                    flex: 4 - _currentStep,
                                    child: Container(
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF2F4F7),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(4),
                                          bottomRight: Radius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Scrollable Body - Flexible ensures it takes remaining space properly
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_currentStep == 0)
                              _buildStep1()
                            else if (_currentStep == 1)
                              _buildStep2()
                            else if (_currentStep == 2)
                              _buildStep3()
                            else if (_currentStep == 3)
                              _buildStep4()
                            else if (_currentStep == 4)
                              _buildStep5(),
                          ],
                        ),
                      ),
                    ),

                    // Fixed Bottom Buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Divider(color: Color(0xFFE5E7EB), height: 1),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: isLoading ? null : _prevStep,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: const BorderSide(color: Color(0xFF276572)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    _currentStep == 0 || _currentStep == 4 ? 'Cancel' : 'Back',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF276572),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: (_isStepValid() && !isLoading) ? _nextStep : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isStepValid()
                                        ? const Color(0xFF2A8090)
                                        : const Color(0xFFD0D5DD),
                                    disabledBackgroundColor: const Color(0xFFD0D5DD),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentStep == 4 ? 'Create Project' : 'Next',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isLoading)
                                        const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      else
                                        Icon(
                                          _currentStep == 4
                                              ? Icons.check_circle
                                              : Icons.arrow_forward_ios,
                                          size: _currentStep == 4 ? 20 : 14,
                                          color: Colors.white,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withAlpha(128),
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2A8090)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'What are you building?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the primary type of your construction project',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 164.5 / 172,
          ),
          itemCount: _projectTypes.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedIndex == index;
            final type = _projectTypes[index];

            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.only(
                  top: 18,
                  right: 22,
                  bottom: 18,
                  left: 22,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF0FBFB)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF309DAA)
                        : Colors.transparent,
                    width: isSelected ? 2 : 0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFEDD5),
                          width: 1.5,
                        ),
                      ),
                      child: SvgPicture.asset(
                        type['icon']!,
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(Color(0xFFF97316), BlendMode.srcIn),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      type['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    String? selectedTypeValue = _selectedIndex != null ? _projectTypes[_selectedIndex!]['value'] : null;
    List<String> subTypes = selectedTypeValue != null ? _subTypeOptions[selectedTypeValue] ?? [] : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          'Project Name*',
          _projectNameController,
          hint: 'e.g., Lekki Residential Estate Phase 2',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Project Description*',
          _projectDescController,
          hint: 'Describe the scope, objectives, and key features...',
          maxLines: 4,
        ),
        const SizedBox(height: 8),
        Text(
          '${_projectDescController.text.length}/1000',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDropdown(
                'Construction Sub-type*',
                _selectedSubType,
                subTypes,
                (val) => setState(() => _selectedSubType = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'Internal Reference ID',
                _referenceIdController,
                hint: 'e.g., CV-2024-001',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Location Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SvgPicture.asset('assets/images/vector-1.svg', width: 24, height: 24),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                'Country*',
                _selectedCountry,
                _locationData.keys.toList(),
                (val) {
                  setState(() {
                    _selectedCountry = val;
                    _selectedState = null;
                    _selectedCity = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown(
                'State/Province*',
                _selectedState,
                _selectedCountry != null
                    ? _locationData[_selectedCountry]!.keys.toList()
                    : [],
                (val) {
                  setState(() {
                    _selectedState = val;
                    _selectedCity = null;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                'City/Town*',
                _selectedCity,
                (_selectedCountry != null && _selectedState != null)
                    ? _locationData[_selectedCountry]![_selectedState]!
                    : [],
                (val) => setState(() => _selectedCity = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'Detailed Address',
                _addressController,
                hint: 'e.g., 12 Admiralty Way',
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Timeline',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SvgPicture.asset('assets/images/routing-2.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker('Start Date*', _startDate, () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _startDate = date);
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDatePicker('End Date*', _endDate, () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _endDate = date);
              }),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriorityButton(
                'normal',
                'Standard',
                SvgPicture.asset('assets/images/logo.svg', width: 16, height: 16),
              ),
              _buildPriorityButton(
                'urgent',
                'Urgent',
                const Icon(Icons.bolt, size: 16, color: Color(0xFF6B7280)),
              ),
              _buildPriorityButton(
                'critical',
                'Critical',
                SvgPicture.asset('assets/images/shield-warning.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(Color(0xFF6B7280), BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budgeting',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              SvgPicture.asset('assets/images/Subtract.svg',
                width: 24,
                height: 24,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _buildDropdown(
                'Currency*',
                _selectedCurrency,
                ['₦', '\$'],
                (val) => setState(() => _selectedCurrency = val ?? '₦'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildTextField(
                'Total Budget Amount*',
                _budgetController,
                hint: 'e.g., 450,000,000',
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assign Contractor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  ),
              ),
              SvgPicture.asset("assets/images/Plate.svg", width: 24, height: 24),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAssignmentOption(
                'direct',
                'Assign\nDirectly',
                'assets/images/group-1.svg',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAssignmentOption(
                'tender',
                'Post to\nTender',
                'assets/images/projects.svg',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAssignmentOption(
                'later',
                'Decide\nLater',
                'assets/images/Calendar-1.svg',
              ),
            ),
          ],
        ),
        if (_assignmentType == 'direct') ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF309DAA)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildContractorCard(
                  'BuildRight Africa',
                  'assets/images/africa.png',
                  4.5,
                  89,
                  'RESIDENTIAL',
                ),
                const SizedBox(height: 12),
                _buildContractorCard(
                  'MetroConstruct Ltd',
                  'assets/images/metro.png',
                  4.5,
                  124,
                  'COMMERCIAL',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.add,
                      size: 20,
                      color: Color(0xFF6B7280),
                    ),
                    label: const Text(
                      'Invite Contractor',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (_assignmentType == 'tender') ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFDED3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.rocket_launch_outlined,
                  color: Color(0xFFEA580C),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Color(0xFFC2410C),
                        fontSize: 13,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: 'Your project will be posted to the '),
                        TextSpan(
                          text: 'Converf Marketplace. ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'Qualified contractors will be able to review your requirements and submit competitive bids.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildDatePicker('Bidding Deadline*', _biddingDeadline, () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (date != null) setState(() => _biddingDeadline = date);
          }),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildStep5() {
    String projectTitle = _projectTypes[_selectedIndex!]['title']!.replaceAll(
      '\n',
      ' ',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project Summary Card (House Icon)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FBFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD8F3F5), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: SvgPicture.asset(
                  'assets/images/home-1.svg',
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(Color(0xFFF97316), BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _projectNameController.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$projectTitle • New Build',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2A8090),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Grid Summary
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildSummaryCard(
              'Location',
              '${_selectedCity ?? ''}, ${_selectedState ?? ''},\n${_selectedCountry ?? ''}',
              'assets/images/map.svg',
            ),
            _buildSummaryCard(
              'Timeline',
              '${_startDate?.toString().substring(0, 10) ?? ''} to\n${_endDate?.toString().substring(0, 10) ?? ''}',
              'assets/images/Calendar.svg',
            ),
            _buildSummaryCard(
              'Budget',
              '$_selectedCurrency${_budgetController.text}',
              'assets/images/bill-check.svg',
            ),
            _buildSummaryCard(
              'Urgency',
              _selectedPriority[0].toUpperCase() +
                  _selectedPriority.substring(1).toLowerCase(),
              'assets/images/Target.svg',
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Assignment Details Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Assignment Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FBFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset(
                        _assignmentType == 'tender'
                            ? 'assets/images/projects.svg'
                            : (_assignmentType == 'direct'
                                ? 'assets/images/group-1.svg'
                                : 'assets/images/Calendar-1.svg'),
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _assignmentType == 'tender'
                                ? 'Public Tender (Deadline: ${_biddingDeadline?.toString().substring(0, 10) ?? ""})'
                                : (_assignmentType == 'direct'
                                    ? 'Direct Assignment'
                                    : 'Decide Later'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Method: ${_assignmentType?.toUpperCase() ?? ""}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _projectDescController.text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B5563),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Agreements
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _confirmInfo,
                onChanged: (val) => setState(() => _confirmInfo = val ?? false),
                activeColor: const Color(0xFF309DAA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'I confirm all information provided is accurate and reflect the true scope of the project.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _agreeTerms,
                onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                activeColor: const Color(0xFF309DAA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'I agree to Converf\'s '),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: const TextStyle(
                        color: Color(0xFF2A8090),
                        fontWeight: FontWeight.w500,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: Navigate to terms and conditions
                        },
                    ),
                    const TextSpan(text: ' regarding project quality monitoring.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, String iconPath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFEAECF0),
                width: 1,
              ),
            ),
            child: SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Color(0xFF98A2B3), BlendMode.srcIn),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 12, ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/images/colourful.png',
              height: 150,
              fit: BoxFit.cover),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F6EC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SvgPicture.asset('assets/images/check.svg',
                  width: 56,
                  height: 56,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Project Created Successfully!',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF171717),
            height: 1.2,
            letterSpacing: -0.48, 
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'Your project "'),
              TextSpan(
                text: _projectNameController.text,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF276572),
                ),
              ),
              const TextSpan(text: '" is ready\nfor management.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reference ID: ',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              Text(
                _referenceIdController.text.isNotEmpty ? _referenceIdController.text : 'CV-2024-001',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: SvgPicture.asset(
                  'assets/images/map.svg',
                  colorFilter: const ColorFilter.mode(Color(0xFF2A8090), BlendMode.srcIn),
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Invite Team Members',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add contractors and team members',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Text(
                    'Invite Team',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A8090),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF2A8090),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          tween: Tween(begin: 1.0, end: 1.0),
          builder: (context, value, child) {
            return SizedBox(
              width: 345,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Animate and Navigate
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF276572),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Go to Project Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/images/projects.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAssignmentOption(String type, String title, String imagePath) {
    bool isSelected = _assignmentType == type;
    return GestureDetector(
      onTap: () => setState(() => _assignmentType = type),
      child: Container(
        height: 132,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FBFB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF309DAA)
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF276572)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(imagePath,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : const Color(0xFF98A2B3),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractorCard(
    String name,
    String image,
    double rating,
    int projects,
    String category,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: image.endsWith('.svg')
                ? SvgPicture.asset(image, width: 48, height: 48, fit: BoxFit.cover)
                : Image.asset(image, width: 48, height: 48, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      'assets/images/mark.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFF7C164)),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        ),
                    ),
                    const SizedBox(width: 12),
                    SvgPicture.asset('assets/images/projects.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(Color(0xFF667185), BlendMode.srcIn)),
                    const SizedBox(width: 4),
                    Text(
                      projects.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF309DAA)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value != null && items.contains(value) ? value : null,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          decoration: InputDecoration(
            hintText:
                hint ?? 'Select ${label.replaceAll('*', '').toLowerCase()}',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF309DAA)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function() onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date == null
                      ? 'Select ${label.replaceAll('*', '')}'
                      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                  style: TextStyle(
                    color: date == null
                        ? Colors.grey.shade400
                        : const Color(0xFF111827),
                    fontSize: 14,
                  ),
                ),
                SvgPicture.asset('assets/images/Calendar-1.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityButton(String priority, String title, Widget icon) {
    bool isActive = _selectedPriority == priority;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = priority),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF0FBFB) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFF309DAA) : Colors.transparent,
            width: isActive ? 1 : 0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? const Color(0xFF2A8090)
                    : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
