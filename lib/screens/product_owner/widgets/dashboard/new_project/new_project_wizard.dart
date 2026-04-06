import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:converf/features/projects/models/project.dart';
import 'package:converf/features/projects/providers/project_providers.dart';
import 'package:converf/features/projects/models/project_payloads.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/models/new_project_state.dart';
import 'providers/wizard_provider.dart';
import 'steps/step_type.dart';
import 'steps/step_details.dart';
import 'steps/step_location.dart';
import 'steps/step_timeline.dart';
import 'steps/step_specialisations.dart';
import 'steps/step_review.dart';
import 'widgets/success_view.dart';

class NewProjectWizard extends ConsumerStatefulWidget {
  final Project? initialProject;
  const NewProjectWizard({super.key, this.initialProject});

  @override
  ConsumerState<NewProjectWizard> createState() => _NewProjectWizardState();
}

class _NewProjectWizardState extends ConsumerState<NewProjectWizard> {
  @override
  void initState() {
    super.initState();
    debugPrint('NewProjectWizard: mounted');
    if (widget.initialProject != null) {
      debugPrint('NewProjectWizard: Resuming project ${widget.initialProject!.id}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final state = ref.read(wizardStateProvider);
        if (state.projectId != widget.initialProject!.id) {
          debugPrint('NewProjectWizard: Initializing state from project...');
          ref.read(wizardStateProvider.notifier).initFromProject(widget.initialProject);
        }
      });
    } else {
      // Starting a brand new project — reset any stale state from previous sessions
      debugPrint('NewProjectWizard: New project — resetting wizard state');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(wizardStateProvider.notifier).reset();
      });
    }
  }

  @override
  void dispose() {
    debugPrint('NewProjectWizard: disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wizardStateProvider);
    final notifier = ref.read(wizardStateProvider.notifier);
    debugPrint('NewProjectWizard: build (currentStep=${state.currentStep}, projectId=${state.projectId})');

    if (state.isSuccess) {
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: const SuccessView(),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Material( // Added Material for standard widget behavior
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E7EC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create New Project',
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Step ${state.currentStep + 1} of 6',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
                        child: const Icon(Icons.close, size: 20, color: Color(0xFF4B5563)),
                      ),
                    ),
                  ],
                ),
              ),
  
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (state.currentStep + 1) / 6,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF309DAA)),
                    minHeight: 4,
                  ),
                ),
              ),
  
              // Step Content
              Flexible( 
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: _buildStepContent(state.currentStep),
                ),
              ),
  
              // Footer
              Padding(
                padding: EdgeInsets.fromLTRB(
                  24, 
                  16, 
                  24, 
                  MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Row(
                  children: [
                    if (state.currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: state.isLoading ? null : () => notifier.updateStep(state.currentStep - 1),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text(
                          'Back', 
                          style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (state.currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isStepValid(state) && !state.isLoading) ? () => _handleNext(context, ref) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF276572),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: state.isLoading 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            state.currentStep == 5 ? 'Confirm & Create' : 'Continue',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );

  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0: return const StepType();
      case 1: return const StepDetails();
      case 2: return const StepLocation();
      case 3: return const StepTimeline();
      case 4: return const StepSpecialisations();
      case 5: return const StepReview();
      default: return const StepType();
    }
  }

  bool _isStepValid(NewProjectState state) {
    bool isValid = false;
    switch (state.currentStep) {
      case 0:
        isValid = state.selectedIndex != null && (state.selectedType != 'commercial' || state.selectedSubType != null);
        break;
      case 1:
        isValid = state.title.trim().isNotEmpty && state.description.trim().isNotEmpty;
        break;
      case 2:
        // Country is now auto-set to Nigeria in StepLocation, but we check for state and city
        isValid = (state.country != null && state.country!.isNotEmpty) && 
                  (state.state != null && state.state!.isNotEmpty) && 
                  (state.city != null && state.city!.isNotEmpty);
        break;
      case 3:
        if (state.startDate == null || state.endDate == null || state.budget.isEmpty || state.assignmentMethod == null) {
          isValid = false;
        } else if (state.assignmentMethod == 'direct' && state.selectedContractorId == null) {
          isValid = false;
        } else if (state.assignmentMethod == 'tender' && state.biddingDeadline == null) {
          isValid = false;
        } else {
          isValid = true;
        }
        break;
      case 4:
        isValid = state.specialisations.isNotEmpty;
        break;
      case 5:
        isValid = state.confirmInfo && state.agreeTerms;
        break;
      default:
        isValid = false;
    }

    if (!isValid) {
      debugPrint('NewProjectWizard: Step ${state.currentStep} is INVALID');
    }
    return isValid;
  }

  /// Builds a complete payload map with ALL fields the backend might need.
  /// Fields the user hasn't filled yet get safe defaults.
  Map<String, dynamic> _buildFullPayload(NewProjectState state, int wizardStep) {
    String cleanBudget = state.budget.replaceAll(',', '').replaceAll(' ', '');
    String cleanCurrency = state.currency;
    if (cleanCurrency == '₦') cleanCurrency = 'NGN';
    if (cleanCurrency == '\$') cleanCurrency = 'USD';
    if (cleanCurrency.isEmpty) cleanCurrency = 'NGN';

    final payload = <String, dynamic>{
      'wizard_step': wizardStep,
      'title': state.title.isNotEmpty ? state.title : 'Untitled Project',
      'description': state.description.isNotEmpty ? state.description : 'No description',
      'construction_type': state.selectedType ?? 'residential',
      if (state.selectedSubType != null) 'construction_sub_type': state.selectedSubType,
      'location': state.address.isNotEmpty ? state.address : 'TBD',
      'city': (state.city != null && state.city!.isNotEmpty) ? state.city : 'TBD',
      'state': (state.state != null && state.state!.isNotEmpty) ? state.state : 'TBD',
      'country': (state.country != null && state.country!.isNotEmpty) ? state.country : 'Nigeria',
      'start_date': state.startDate != null
          ? DateFormat('yyyy-MM-dd').format(state.startDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'end_date': state.endDate != null
          ? DateFormat('yyyy-MM-dd').format(state.endDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 30))),
      'budget': cleanBudget.isNotEmpty ? cleanBudget : '0',
      'currency': cleanCurrency,
      'urgency_level': state.urgencyLevel.isNotEmpty ? state.urgencyLevel : 'low',
      'assignment_method': state.assignmentMethod ?? 'tender',
      'confirm': state.confirmInfo,
      'agree_terms': state.agreeTerms,
    };

    if (state.selectedContractorId != null) {
      payload['contractor_id'] = state.selectedContractorId;
    }
    // Backend requires bidding_deadline when assignment_method is 'tender'
    // AND it must be BEFORE start_date
    final effectiveStartDate = state.startDate ?? DateTime.now();
    if (state.biddingDeadline != null) {
      payload['bidding_deadline'] = DateFormat('yyyy-MM-dd').format(state.biddingDeadline!);
    } else if (payload['assignment_method'] == 'tender') {
      payload['bidding_deadline'] = DateFormat('yyyy-MM-dd').format(
        effectiveStartDate.subtract(const Duration(days: 7)),
      );
    }
    payload['specialisations'] = state.specialisations.isNotEmpty
        ? state.specialisations
        : ['residential'];

    return payload;
  }

  Future<void> _handleNext(BuildContext context, WidgetRef ref) async {
    final state = ref.read(wizardStateProvider);
    final notifier = ref.read(wizardStateProvider.notifier);
    final apiNotifier = ref.read(projectWizardProvider.notifier);

    try {
      notifier.setLoading(true);
      debugPrint('--- Wizard Next Clicked ---');
      debugPrint('Current Step: ${state.currentStep}');
      debugPrint('Project ID: ${state.projectId}');

      if (state.currentStep == 0) {
        debugPrint('Step 0 -> Step 1 (Local only)');
        notifier.updateStep(1);
      } else if (state.currentStep == 1) {
        if (state.projectId == null || state.projectId!.isEmpty) {
          debugPrint('Step 1: Calling StartWizard (POST)...');
          final res = await apiNotifier.startWizard(StartWizardPayload(
            title: state.title,
            description: state.description,
            constructionType: state.selectedType ?? 'residential',
            constructionSubType: state.selectedSubType,
            wizardStep: 1,
          ));
          debugPrint('Step 1: StartWizard Success. Received ID: "${res.id}"');
          
          if (res.id.isEmpty) {
            debugPrint('Error: API returned success but ID was empty!');
            throw Exception("Server failed to create project session (empty ID).");
          }
          
          notifier.setProjectId(res.id);
        } else {
          // PATCH: send ALL fields to satisfy backend validation
          final payload = _buildFullPayload(state, 1);
          debugPrint('Step 1 PATCH payload: $payload');
          await apiNotifier.updateBasicInfo(
            state.projectId!,
            UpdateBasicInfoPayload(
              wizardStep: 1,
              title: payload['title'],
              description: payload['description'],
              constructionType: payload['construction_type'],
              constructionSubType: payload['construction_sub_type'],
              location: payload['location'],
              city: payload['city'],
              state: payload['state'],
              country: payload['country'],
              startDate: payload['start_date'],
              endDate: payload['end_date'],
              budget: payload['budget'],
              currency: payload['currency'],
              urgencyLevel: payload['urgency_level'],
              assignmentMethod: payload['assignment_method'],
              contractorId: payload['contractor_id'],
              biddingDeadline: payload['bidding_deadline'],
              specialisations: payload['specialisations'] != null ? List<String>.from(payload['specialisations']) : null,
              confirm: payload['confirm'],
              agreeTerms: payload['agree_terms'],
            ),
          );
          debugPrint('Step 1: UpdateBasicInfo Success');
        }
        notifier.updateStep(2);
      } else {
        // Steps 2 and above require projectId
        if (state.projectId == null || state.projectId!.isEmpty) {
          debugPrint('Error: Missing Project ID for Step ${state.currentStep}');
          throw Exception("Project session expired. Please restart the wizard.");
        }

        // Build the full payload with ALL fields for every PATCH
        final payload = _buildFullPayload(state, state.currentStep);
        debugPrint('Step ${state.currentStep} PATCH payload: $payload');

        if (state.currentStep == 2) {
          await apiNotifier.updateLocation(
            state.projectId!,
            UpdateLocationPayload(
              wizardStep: 2,
              location: payload['location'],
              city: payload['city'],
              state: payload['state'],
              country: payload['country'],
              title: payload['title'],
              description: payload['description'],
              constructionType: payload['construction_type'],
              constructionSubType: payload['construction_sub_type'],
              startDate: payload['start_date'],
              endDate: payload['end_date'],
              budget: payload['budget'],
              currency: payload['currency'],
              urgencyLevel: payload['urgency_level'],
              assignmentMethod: payload['assignment_method'],
              contractorId: payload['contractor_id'],
              biddingDeadline: payload['bidding_deadline'],
              specialisations: payload['specialisations'] != null ? List<String>.from(payload['specialisations']) : null,
              confirm: payload['confirm'],
              agreeTerms: payload['agree_terms'],
            ),
          );
          debugPrint('Step 2: UpdateLocation Success');
          notifier.updateStep(3);
        } else if (state.currentStep == 3) {
          await apiNotifier.updateTimelineBudget(
            state.projectId!,
            UpdateTimelineBudgetPayload(
              wizardStep: 3,
              startDate: payload['start_date'],
              endDate: payload['end_date'],
              budget: payload['budget'],
              currency: payload['currency'],
              urgencyLevel: payload['urgency_level'],
              assignmentMethod: payload['assignment_method']!,
              contractorId: payload['contractor_id'],
              biddingDeadline: payload['bidding_deadline'],
              title: payload['title'],
              description: payload['description'],
              constructionType: payload['construction_type'],
              constructionSubType: payload['construction_sub_type'],
              location: payload['location'],
              city: payload['city'],
              state: payload['state'],
              country: payload['country'],
              specialisations: payload['specialisations'] != null ? List<String>.from(payload['specialisations']) : null,
              confirm: payload['confirm'],
              agreeTerms: payload['agree_terms'],
            ),
          );
          debugPrint('Step 3: UpdateTimelineBudget Success');
          notifier.updateStep(4);
        } else if (state.currentStep == 4) {
          await apiNotifier.updateSpecialisations(
            state.projectId!,
            UpdateSpecialisationsPayload(
              wizardStep: 4,
              specialisations: state.specialisations,
              title: payload['title'],
              description: payload['description'],
              constructionType: payload['construction_type'],
              constructionSubType: payload['construction_sub_type'],
              location: payload['location'],
              city: payload['city'],
              state: payload['state'],
              country: payload['country'],
              startDate: payload['start_date'],
              endDate: payload['end_date'],
              budget: payload['budget'],
              currency: payload['currency'],
              urgencyLevel: payload['urgency_level'],
              assignmentMethod: payload['assignment_method'],
              contractorId: payload['contractor_id'],
              biddingDeadline: payload['bidding_deadline'],
              confirm: payload['confirm'],
              agreeTerms: payload['agree_terms'],
            ),
          );
          debugPrint('Step 4: UpdateSpecialisations Success');
          notifier.updateStep(5);
        } else if (state.currentStep == 5) {
          await apiNotifier.confirmProject(
            state.projectId!,
            ConfirmProjectPayload(
              wizardStep: 5,
              confirm: state.confirmInfo,
              agreeTerms: state.agreeTerms,
              title: payload['title'],
              description: payload['description'],
              constructionType: payload['construction_type'],
              constructionSubType: payload['construction_sub_type'],
              location: payload['location'],
              city: payload['city'],
              state: payload['state'],
              country: payload['country'],
              startDate: payload['start_date'],
              endDate: payload['end_date'],
              budget: payload['budget'],
              currency: payload['currency'],
              urgencyLevel: payload['urgency_level'],
              assignmentMethod: payload['assignment_method'],
              contractorId: payload['contractor_id'],
              biddingDeadline: payload['bidding_deadline'],
              specialisations: payload['specialisations'] != null ? List<String>.from(payload['specialisations']) : null,
            ),
          );
          debugPrint('Step 5: ConfirmProject Success');
          
          if (state.assignmentMethod == 'direct' && state.selectedContractorId != null) {
            debugPrint('Step 6: Calling FinalAssignContractor (PATCH) for ${state.projectId}...');
            await apiNotifier.finalAssignContractor(
              state.projectId!,
              FinalAssignPayload(
                contractorId: state.selectedContractorId!,
                wizardStep: 6,
                confirm: state.confirmInfo,
                agreeTerms: state.agreeTerms,
                title: payload['title'],
                description: payload['description'],
                constructionType: payload['construction_type'],
                constructionSubType: payload['construction_sub_type'],
                location: payload['location'],
                city: payload['city'],
                state: payload['state'],
                country: payload['country'],
                startDate: payload['start_date'],
                endDate: payload['end_date'],
                budget: payload['budget'],
                currency: payload['currency'],
                urgencyLevel: payload['urgency_level'],
                assignmentMethod: payload['assignment_method'],
                biddingDeadline: payload['bidding_deadline'],
                specialisations: payload['specialisations'] != null ? List<String>.from(payload['specialisations']) : null,
              ),
            );
            debugPrint('Step 6: FinalAssignContractor Success');
          }
          
          notifier.setSuccess(true);
        }
      }
      debugPrint('Wizard Move Success');
    } catch (e) {
      debugPrint('Wizard Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'), 
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      notifier.setLoading(false);
    }
  }
}
