
class NewProjectState {
  final int currentStep;
  final String? projectId;
  
  // Step 0
  final int? selectedIndex;
  final String? selectedType;
  
  // Step 1
  final String title;
  final String description;
  final String? selectedSubType;
  
  // Step 2
  final String? country;
  final String? state;
  final String? city;
  final String address;
  
  // Step 3
  final DateTime? startDate;
  final DateTime? endDate;
  final String urgencyLevel;
  final String currency;
  final String budget;
  final String? assignmentMethod;
  final DateTime? biddingDeadline;
  final String? selectedContractorId;
  
  // Step 4
  final List<String> specialisations;
  
  // Step 5
  final bool confirmInfo;
  final bool agreeTerms;
  final bool isLoading;
  final bool isSuccess;

  const NewProjectState({
    this.currentStep = 0,
    this.projectId,
    this.selectedIndex,
    this.selectedType,
    this.title = '',
    this.description = '',
    this.selectedSubType,
    this.country,
    this.state,
    this.city,
    this.address = '',
    this.startDate,
    this.endDate,
    this.urgencyLevel = 'low',
    this.currency = 'NGN',
    this.budget = '',
    this.assignmentMethod,
    this.biddingDeadline,
    this.selectedContractorId,
    this.specialisations = const [],
    this.confirmInfo = false,
    this.agreeTerms = false,
    this.isLoading = false,
    this.isSuccess = false,
  });

  static const _sentinel = Object();

  NewProjectState copyWith({
    int? currentStep,
    String? projectId,
    int? selectedIndex,
    String? selectedType,
    String? title,
    String? description,
    dynamic selectedSubType = _sentinel,
    dynamic country = _sentinel,
    dynamic state = _sentinel,
    dynamic city = _sentinel,
    String? address,
    dynamic startDate = _sentinel,
    dynamic endDate = _sentinel,
    String? urgencyLevel,
    String? currency,
    String? budget,
    dynamic assignmentMethod = _sentinel,
    dynamic biddingDeadline = _sentinel,
    dynamic selectedContractorId = _sentinel,
    List<String>? specialisations,
    bool? confirmInfo,
    bool? agreeTerms,
    bool? isLoading,
    bool? isSuccess,
  }) {
    return NewProjectState(
      currentStep: currentStep ?? this.currentStep,
      projectId: projectId ?? this.projectId,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedType: selectedType ?? this.selectedType,
      title: title ?? this.title,
      description: description ?? this.description,
      selectedSubType: selectedSubType == _sentinel ? this.selectedSubType : selectedSubType as String?,
      country: country == _sentinel ? this.country : country as String?,
      state: state == _sentinel ? this.state : state as String?,
      city: city == _sentinel ? this.city : city as String?,
      address: address ?? this.address,
      startDate: startDate == _sentinel ? this.startDate : startDate as DateTime?,
      endDate: endDate == _sentinel ? this.endDate : endDate as DateTime?,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      currency: currency ?? this.currency,
      budget: budget ?? this.budget,
      assignmentMethod: assignmentMethod == _sentinel ? this.assignmentMethod : assignmentMethod as String?,
      biddingDeadline: biddingDeadline == _sentinel ? this.biddingDeadline : biddingDeadline as DateTime?,
      selectedContractorId: selectedContractorId == _sentinel ? this.selectedContractorId : selectedContractorId as String?,
      specialisations: specialisations ?? this.specialisations,
      confirmInfo: confirmInfo ?? this.confirmInfo,
      agreeTerms: agreeTerms ?? this.agreeTerms,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
