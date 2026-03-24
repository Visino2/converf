import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                        onPressed: () => notifier.updateStep(state.currentStep - 1),
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
                      onPressed: _isStepValid(state) ? () => _handleNext(context, ref) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF276572),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: Text(
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
    switch (state.currentStep) {
      case 0:
        return state.selectedIndex != null && (state.selectedType != 'commercial' || state.selectedSubType != null);
      case 1:
        return state.title.isNotEmpty && state.description.isNotEmpty;
      case 2:
        return state.country != null && state.state != null && state.city != null;
      case 3:
        if (state.startDate == null || state.endDate == null || state.budget.isEmpty || state.assignmentMethod == null) return false;
        if (state.assignmentMethod == 'direct' && state.selectedContractorId == null) return false;
        if (state.assignmentMethod == 'tender' && state.biddingDeadline == null) return false;
        return true;
      case 4:
        return state.specialisations.isNotEmpty;
      case 5:
        return state.confirmInfo && state.agreeTerms;
      default:
        return false;
    }
  }

  Future<void> _handleNext(BuildContext context, WidgetRef ref) async {
    final state = ref.read(wizardStateProvider);
    final notifier = ref.read(wizardStateProvider.notifier);
    final apiNotifier = ref.read(projectWizardProvider.notifier);

    try {
      debugPrint('--- Wizard Next Clicked ---');
      debugPrint('Current Step: ${state.currentStep}');
      debugPrint('Project ID: ${state.projectId}');

      if (state.currentStep == 0) {
        debugPrint('Step 0 -> Step 1 (Local only)');
        notifier.updateStep(1);
      } else if (state.currentStep == 1) {
        // Step 1: Start Wizard (POST) or Update (PATCH)
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
          debugPrint('Step 1: Calling UpdateBasicInfo (PATCH) for "${state.projectId}"...');
          await apiNotifier.updateBasicInfo(
            state.projectId!,
            UpdateBasicInfoPayload(
              wizardStep: 1,
              title: state.title,
              description: state.description,
              constructionType: state.selectedType,
              constructionSubType: state.selectedSubType,
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

        if (state.currentStep == 2) {
          // Step 2: Location
          debugPrint('Step 2: Calling UpdateLocation (PATCH) for ${state.projectId}...');
          await apiNotifier.updateLocation(
            state.projectId!,
            UpdateLocationPayload(
              wizardStep: 2,
              location: state.address,
              city: state.city ?? '',
              state: state.state ?? '',
              country: state.country ?? '',
            ),
          );
          debugPrint('Step 2: UpdateLocation Success');
          notifier.updateStep(3);
        } else if (state.currentStep == 3) {
          // Step 3: Timeline & Budget
          debugPrint('Step 3: Calling UpdateTimelineBudget (PATCH) for ${state.projectId}...');
          final cleanBudget = state.budget.replaceAll(',', '').replaceAll(' ', '');
          String cleanCurrency = state.currency;
          if (cleanCurrency == '₦') cleanCurrency = 'NGN';
          if (cleanCurrency == '\$') cleanCurrency = 'USD';
          if (cleanCurrency.isEmpty) cleanCurrency = 'NGN';

          await apiNotifier.updateTimelineBudget(
            state.projectId!,
            UpdateTimelineBudgetPayload(
              wizardStep: 3,
              startDate: state.startDate?.toIso8601String() ?? '',
              endDate: state.endDate?.toIso8601String() ?? '',
              budget: double.tryParse(cleanBudget) ?? 0,
              currency: cleanCurrency,
              urgencyLevel: state.urgencyLevel,
              assignmentMethod: state.assignmentMethod ?? 'random',
              contractorId: state.selectedContractorId,
              biddingDeadline: state.biddingDeadline?.toIso8601String(),
            ),
          );
          debugPrint('Step 3: UpdateTimelineBudget Success');
          notifier.updateStep(4);
        } else if (state.currentStep == 4) {
          // Step 4: Specialisations
          debugPrint('Step 4: Calling UpdateSpecialisations (PATCH) for ${state.projectId}...');
          await apiNotifier.updateSpecialisations(
            state.projectId!,
            UpdateSpecialisationsPayload(
              wizardStep: 4,
              specialisations: state.specialisations,
            ),
          );
          debugPrint('Step 4: UpdateSpecialisations Success');
          notifier.updateStep(5);
        } else if (state.currentStep == 5) {
          // Step 5: Review & Confirm
          debugPrint('Step 5: Calling ConfirmProject (PATCH) for ${state.projectId}...');
          await apiNotifier.confirmProject(
            state.projectId!,
            ConfirmProjectPayload(
              wizardStep: 5,
              confirm: state.confirmInfo,
              agreeTerms: state.agreeTerms,
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
    }
  }
}
