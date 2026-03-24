import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/features/projects/models/project.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/models/new_project_state.dart';

class WizardStateNotifier extends Notifier<NewProjectState> {
  @override
  NewProjectState build() {
    return const NewProjectState();
  }

  void updateState(NewProjectState newState) {
    state = newState;
  }

  void updateStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void setProjectId(String id) {
    state = state.copyWith(projectId: id);
  }

  void updateBasicInfo({
    String? title,
    String? description,
    int? selectedIndex,
    String? selectedType,
    String? selectedSubType,
  }) {
    state = state.copyWith(
      title: title ?? state.title,
      description: description ?? state.description,
      selectedIndex: selectedIndex ?? state.selectedIndex,
      selectedType: selectedType ?? state.selectedType,
      selectedSubType: selectedSubType ?? state.selectedSubType,
    );
  }

  void updateLocation({
    String? country,
    String? stateName,
    String? city,
    String? address,
  }) {
    state = state.copyWith(
      country: country ?? state.country,
      state: stateName ?? state.state,
      city: city ?? state.city,
      address: address ?? state.address,
    );
  }

  void updateTimelineBudget({
    DateTime? startDate,
    DateTime? endDate,
    String? urgencyLevel,
    String? currency,
    String? budget,
    String? assignmentMethod,
    DateTime? biddingDeadline,
    String? selectedContractorId,
  }) {
    state = state.copyWith(
      startDate: startDate ?? state.startDate,
      endDate: endDate ?? state.endDate,
      urgencyLevel: urgencyLevel ?? state.urgencyLevel,
      currency: currency ?? state.currency,
      budget: budget ?? state.budget,
      assignmentMethod: assignmentMethod ?? state.assignmentMethod,
      biddingDeadline: biddingDeadline ?? state.biddingDeadline,
      selectedContractorId: selectedContractorId ?? state.selectedContractorId,
    );
  }

  void updateSpecialisations(List<String> specialisations) {
    state = state.copyWith(specialisations: specialisations);
  }

  void updateReview({bool? confirmInfo, bool? agreeTerms}) {
    state = state.copyWith(
      confirmInfo: confirmInfo ?? state.confirmInfo,
      agreeTerms: agreeTerms ?? state.agreeTerms,
    );
  }

  void setSuccess(bool success) {
    state = state.copyWith(isSuccess: success);
  }

  void initFromProject(Project? project) {
    if (project == null) return;
    

    int step = project.currentStep;
    if (step > 5) step = 5; 
    if (project.status != ProjectStatus.draft && step == 0) step = 1;

    String currency = project.currency;
    if (currency == '₦') currency = 'NGN';
    if (currency == '\$') currency = 'USD';
    if (currency.isEmpty) currency = 'NGN';

    state = state.copyWith(
      projectId: project.id,
      currentStep: step,
      title: project.title,
      description: project.description,
      selectedType: project.constructionType.toLowerCase(),
      selectedSubType: project.constructionSubType,
      country: project.country,
      state: project.state,
      city: project.city,
      address: project.location,
      startDate: DateTime.tryParse(project.startDate),
      endDate: DateTime.tryParse(project.endDate),
      budget: project.budget,
      currency: currency,
      urgencyLevel: project.urgencyLevel.name,
      assignmentMethod: project.assignmentMethod,
      biddingDeadline: project.biddingDeadline != null ? DateTime.tryParse(project.biddingDeadline!) : null,
      selectedContractorId: project.contractorId,
      specialisations: project.specialisations,
    );
  }

  void reset() {
    state = const NewProjectState();
  }
}

final wizardStateProvider = NotifierProvider<WizardStateNotifier, NewProjectState>(WizardStateNotifier.new);
