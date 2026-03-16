class StartWizardPayload {
  final String? title;
  final String? description;
  final String constructionType;
  final String? constructionSubType;

  StartWizardPayload({
    this.title,
    this.description,
    required this.constructionType,
    this.constructionSubType,
  });

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      'construction_type': constructionType,
      if (constructionSubType != null) 'construction_sub_type': constructionSubType,
    };
  }
}

class UpdateBasicInfoPayload {
  final int wizardStep;
  final String title;
  final String description;
  final String? constructionSubType;

  UpdateBasicInfoPayload({
    required this.wizardStep,
    required this.title,
    required this.description,
    this.constructionSubType,
  });

  Map<String, dynamic> toJson() {
    return {
      'wizard_step': wizardStep,
      'title': title,
      'description': description,
      if (constructionSubType != null) 'construction_sub_type': constructionSubType,
    };
  }
}

class UpdateLocationPayload {
  final int wizardStep;
  final String location;
  final String city;
  final String state;
  final String country;

  UpdateLocationPayload({
    required this.wizardStep,
    required this.location,
    required this.city,
    required this.state,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'wizard_step': wizardStep,
      'location': location,
      'city': city,
      'state': state,
      'country': country,
    };
  }
}

class UpdateTimelineBudgetPayload {
  final int wizardStep;
  final String startDate;
  final String endDate;
  final num budget;
  final String currency;
  final String urgencyLevel;
  final String assignmentMethod;
  final String? contractorId;
  final String? biddingDeadline;

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
    };
  }
}

class UpdateSpecialisationsPayload {
  final int wizardStep;
  final List<String> specialisations;

  UpdateSpecialisationsPayload({
    required this.wizardStep,
    required this.specialisations,
  });

  Map<String, dynamic> toJson() {
    return {
      'wizard_step': wizardStep,
      'specialisations': specialisations,
    };
  }
}

class ConfirmProjectPayload {
  final int wizardStep;
  final bool confirm;

  ConfirmProjectPayload({
    required this.wizardStep,
    required this.confirm,
  });

  Map<String, dynamic> toJson() {
    return {
      'wizard_step': wizardStep,
      'confirm': confirm,
    };
  }
}

class FinalAssignPayload {
  final int wizardStep;
  final String contractorId;

  FinalAssignPayload({
    required this.wizardStep,
    required this.contractorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'wizard_step': wizardStep,
      'contractor_id': contractorId,
    };
  }
}
