class StartWizardPayload {
  final String title;
  final String description;
  final String constructionType;
  final String? constructionSubType;
  final int wizardStep;

  StartWizardPayload({
    required this.title,
    required this.description,
    required this.constructionType,
    this.constructionSubType,
    required this.wizardStep,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'construction_type': constructionType,
      if (constructionSubType != null) 'construction_sub_type': constructionSubType,
      'wizard_step': wizardStep,
    };
  }
}

class UpdateBasicInfoPayload {
  final int wizardStep;
  final String title;
  final String description;
  final String? constructionType;
  final String? constructionSubType;
  final String? location;
  final String? city;
  final String? state;
  final String? country;
  final String? startDate;
  final String? endDate;
  final String? budget;
  final String? currency;
  final String? urgencyLevel;
  final String? assignmentMethod;
  final String? contractorId;
  final String? biddingDeadline;
  final List<String>? specialisations;
  final bool? confirm;
  final bool? agreeTerms;

  UpdateBasicInfoPayload({
    required this.wizardStep,
    required this.title,
    required this.description,
    this.constructionType,
    this.constructionSubType,
    this.location,
    this.city,
    this.state,
    this.country,
    this.startDate,
    this.endDate,
    this.budget,
    this.currency,
    this.urgencyLevel,
    this.assignmentMethod,
    this.contractorId,
    this.biddingDeadline,
    this.specialisations,
    this.confirm,
    this.agreeTerms,
  });

  Map<String, dynamic> toJson() {
    return {
      'wizard_step': wizardStep,
      'title': title,
      'description': description,
      if (constructionType != null) 'construction_type': constructionType,
      if (constructionSubType != null) 'construction_sub_type': constructionSubType,
      if (location != null) 'location': location,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (budget != null) 'budget': budget,
      if (currency != null) 'currency': currency,
      if (urgencyLevel != null) 'urgency_level': urgencyLevel,
      if (assignmentMethod != null) 'assignment_method': assignmentMethod,
      if (contractorId != null) 'contractor_id': contractorId,
      if (biddingDeadline != null) 'bidding_deadline': biddingDeadline,
      if (specialisations != null && specialisations!.isNotEmpty) 'specialisations': specialisations,
      if (confirm != null) 'confirm': confirm,
      if (agreeTerms != null) 'agree_terms': agreeTerms,
    };
  }
}

class UpdateLocationPayload {
  final int wizardStep;
  final String location;
  final String city;
  final String state;
  final String country;
  final String? title;
  final String? description;
  final String? constructionType;
  final String? constructionSubType;
  final String? startDate;
  final String? endDate;
  final String? budget;
  final String? currency;
  final String? urgencyLevel;
  final String? assignmentMethod;
  final String? contractorId;
  final String? biddingDeadline;
  final List<String>? specialisations;
  final bool? confirm;
  final bool? agreeTerms;

  UpdateLocationPayload({
    required this.wizardStep,
    required this.location,
    required this.city,
    required this.state,
    required this.country,
    this.title,
    this.description,
    this.constructionType,
    this.constructionSubType,
    this.startDate,
    this.endDate,
    this.budget,
    this.currency,
    this.urgencyLevel,
    this.assignmentMethod,
    this.contractorId,
    this.biddingDeadline,
    this.specialisations,
    this.confirm,
    this.agreeTerms,
  });

  Map<String, dynamic> toJson() {
    return {
      'wizard_step': wizardStep,
      'location': location,
      'city': city,
      'state': state,
      'country': country,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (constructionType != null) 'construction_type': constructionType,
      if (constructionSubType != null) 'construction_sub_type': constructionSubType,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (budget != null) 'budget': budget,
      if (currency != null) 'currency': currency,
      if (urgencyLevel != null) 'urgency_level': urgencyLevel,
      if (assignmentMethod != null) 'assignment_method': assignmentMethod,
      if (contractorId != null) 'contractor_id': contractorId,
      if (biddingDeadline != null) 'bidding_deadline': biddingDeadline,
      if (specialisations != null && specialisations!.isNotEmpty) 'specialisations': specialisations,
      if (confirm != null) 'confirm': confirm,
      if (agreeTerms != null) 'agree_terms': agreeTerms,
    };
  }
}

class UpdateTimelineBudgetPayload {
  final int wizardStep;
  final String startDate;
  final String endDate;
  final String budget;
  final String currency;
  final String urgencyLevel;
  final String assignmentMethod;
  final String? contractorId;
  final String? biddingDeadline;
  final String? title;
  final String? description;
  final String? constructionType;
  final String? constructionSubType;
  final String? location;
  final String? city;
  final String? state;
  final String? country;
  final List<String>? specialisations;
  final bool? confirm;
  final bool? agreeTerms;

  UpdateTimelineBudgetPayload({
    required this.wizardStep,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.currency,
    required this.urgencyLevel,
    required this.assignmentMethod,
    this.contractorId,
    this.biddingDeadline,
    this.title,
    this.description,
    this.constructionType,
    this.constructionSubType,
    this.location,
    this.city,
    this.state,
    this.country,
    this.specialisations,
    this.confirm,
    this.agreeTerms,
  });

  Map<String, dynamic> toJson() {
    return {
      'wizard_step': wizardStep,
      'start_date': startDate,
      'end_date': endDate,
      'budget': budget,
      'currency': currency,
      'urgency_level': urgencyLevel,
      'assignment_method': assignmentMethod,
      if (contractorId != null) 'contractor_id': contractorId,
      if (biddingDeadline != null) 'bidding_deadline': biddingDeadline,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (constructionType != null) 'construction_type': constructionType,
      if (constructionSubType != null) 'construction_sub_type': constructionSubType,
      if (location != null) 'location': location,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (specialisations != null && specialisations!.isNotEmpty) 'specialisations': specialisations,
      if (confirm != null) 'confirm': confirm,
      if (agreeTerms != null) 'agree_terms': agreeTerms,
    };
  }
}

class UpdateSpecialisationsPayload {
  final int wizardStep;
  final List<String> specialisations;
  final String? title;
  final String? description;
  final String? constructionType;
  final String? constructionSubType;
  final String? location;
  final String? city;
  final String? state;
  final String? country;
  final String? startDate;
  final String? endDate;
  final String? budget;
  final String? currency;
  final String? urgencyLevel;
  final String? assignmentMethod;
  final String? contractorId;
  final String? biddingDeadline;
  final bool? confirm;
  final bool? agreeTerms;

  UpdateSpecialisationsPayload({
    required this.wizardStep,
    required this.specialisations,
    this.title,
    this.description,
    this.constructionType,
    this.constructionSubType,
    this.location,
    this.city,
    this.state,
    this.country,
    this.startDate,
    this.endDate,
    this.budget,
    this.currency,
    this.urgencyLevel,
    this.assignmentMethod,
    this.contractorId,
    this.biddingDeadline,
    this.confirm,
    this.agreeTerms,
  });

  Map<String, dynamic> toJson() {
    return {
      'wizard_step': wizardStep,
      'specialisations': specialisations,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (constructionType != null) 'construction_type': constructionType,
      if (constructionSubType != null) 'construction_sub_type': constructionSubType,
      if (location != null) 'location': location,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (budget != null) 'budget': budget,
      if (currency != null) 'currency': currency,
      if (urgencyLevel != null) 'urgency_level': urgencyLevel,
      if (assignmentMethod != null) 'assignment_method': assignmentMethod,
      if (contractorId != null) 'contractor_id': contractorId,
      if (biddingDeadline != null) 'bidding_deadline': biddingDeadline,
      if (confirm != null) 'confirm': confirm,
      if (agreeTerms != null) 'agree_terms': agreeTerms,
    };
  }
}

class ConfirmProjectPayload {
  final int wizardStep;
  final bool confirm;
  final bool agreeTerms;
  final String? title;
  final String? description;
  final String? constructionType;
  final String? constructionSubType;
  final String? location;
  final String? city;
  final String? state;
  final String? country;
  final String? startDate;
  final String? endDate;
  final String? budget;
  final String? currency;
  final String? urgencyLevel;
  final String? assignmentMethod;
  final String? contractorId;
  final String? biddingDeadline;
  final List<String>? specialisations;

  ConfirmProjectPayload({
    required this.wizardStep,
    required this.confirm,
    required this.agreeTerms,
    this.title,
    this.description,
    this.constructionType,
    this.constructionSubType,
    this.location,
    this.city,
    this.state,
    this.country,
    this.startDate,
    this.endDate,
    this.budget,
    this.currency,
    this.urgencyLevel,
    this.assignmentMethod,
    this.contractorId,
    this.biddingDeadline,
    this.specialisations,
  });

  Map<String, dynamic> toJson() {
    return {
      'wizard_step': wizardStep,
      'confirm': confirm,
      'agree_terms': agreeTerms,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (constructionType != null) 'construction_type': constructionType,
      if (constructionSubType != null) 'construction_sub_type': constructionSubType,
      if (location != null) 'location': location,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (budget != null) 'budget': budget,
      if (currency != null) 'currency': currency,
      if (urgencyLevel != null) 'urgency_level': urgencyLevel,
      if (assignmentMethod != null) 'assignment_method': assignmentMethod,
      if (contractorId != null) 'contractor_id': contractorId,
      if (biddingDeadline != null) 'bidding_deadline': biddingDeadline,
      if (specialisations != null && specialisations!.isNotEmpty) 'specialisations': specialisations,
    };
  }
}

class FinalAssignPayload {
  final int wizardStep;
  final String contractorId;
  final bool? confirm;
  final bool? agreeTerms;
  final String? title;
  final String? description;
  final String? constructionType;
  final String? constructionSubType;
  final String? location;
  final String? city;
  final String? state;
  final String? country;
  final String? startDate;
  final String? endDate;
  final String? budget;
  final String? currency;
  final String? urgencyLevel;
  final String? assignmentMethod;
  final String? biddingDeadline;
  final List<String>? specialisations;

  FinalAssignPayload({
    required this.wizardStep,
    required this.contractorId,
    this.confirm,
    this.agreeTerms,
    this.title,
    this.description,
    this.constructionType,
    this.constructionSubType,
    this.location,
    this.city,
    this.state,
    this.country,
    this.startDate,
    this.endDate,
    this.budget,
    this.currency,
    this.urgencyLevel,
    this.assignmentMethod,
    this.biddingDeadline,
    this.specialisations,
  });

  Map<String, dynamic> toJson() {
    return {
      'wizard_step': wizardStep,
      'contractor_id': contractorId,
      if (confirm != null) 'confirm': confirm,
      if (agreeTerms != null) 'agree_terms': agreeTerms,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (constructionType != null) 'construction_type': constructionType,
      if (constructionSubType != null) 'construction_sub_type': constructionSubType,
      if (location != null) 'location': location,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (budget != null) 'budget': budget,
      if (currency != null) 'currency': currency,
      if (urgencyLevel != null) 'urgency_level': urgencyLevel,
      if (assignmentMethod != null) 'assignment_method': assignmentMethod,
      if (biddingDeadline != null) 'bidding_deadline': biddingDeadline,
      if (specialisations != null && specialisations!.isNotEmpty) 'specialisations': specialisations,
    };
  }
}
