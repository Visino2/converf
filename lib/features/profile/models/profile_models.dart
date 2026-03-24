class NotificationSettings {
  final bool emailNotifications;
  final bool newMessages;
  final bool ballInCourtUpdates;
  final bool? pushNotifications;
  // Client specific
  final bool? newBids;
  final bool? milestoneCompletions;
  final bool? invoiceAlerts;
  final bool? inspectionReports;
  final bool? teamInvitationAccepted;
  final bool? projectPublished;
  // Contractor specific
  final bool? newProjectMatches;
  final bool? paymentReceived;
  final bool? qualityScoreAlerts;
  final bool? bidStatusUpdates;

  NotificationSettings({
    required this.emailNotifications,
    required this.newMessages,
    required this.ballInCourtUpdates,
    this.pushNotifications,
    this.newBids,
    this.milestoneCompletions,
    this.invoiceAlerts,
    this.inspectionReports,
    this.teamInvitationAccepted,
    this.projectPublished,
    this.newProjectMatches,
    this.paymentReceived,
    this.qualityScoreAlerts,
    this.bidStatusUpdates,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      emailNotifications: json['email_notifications'] == true,
      newMessages: json['new_messages'] == true,
      ballInCourtUpdates: json['ball_in_court_updates'] == true,
      pushNotifications: json['push_notifications'] as bool?,
      newBids: json['new_bids'] as bool?,
      milestoneCompletions: json['milestone_completions'] as bool?,
      invoiceAlerts: json['invoice_alerts'] as bool?,
      inspectionReports: json['inspection_reports'] as bool?,
      teamInvitationAccepted: json['team_invitation_accepted'] as bool?,
      projectPublished: json['project_published'] as bool?,
      newProjectMatches: json['new_project_matches'] as bool?,
      paymentReceived: json['payment_received'] as bool?,
      qualityScoreAlerts: json['quality_score_alerts'] as bool?,
      bidStatusUpdates: json['bid_status_updates'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email_notifications': emailNotifications,
      'new_messages': newMessages,
      'ball_in_court_updates': ballInCourtUpdates,
      if (pushNotifications != null) 'push_notifications': pushNotifications,
      if (newBids != null) 'new_bids': newBids,
      if (milestoneCompletions != null) 'milestone_completions': milestoneCompletions,
      if (invoiceAlerts != null) 'invoice_alerts': invoiceAlerts,
      if (inspectionReports != null) 'inspection_reports': inspectionReports,
      if (teamInvitationAccepted != null) 'team_invitation_accepted': teamInvitationAccepted,
      if (projectPublished != null) 'project_published': projectPublished,
      if (newProjectMatches != null) 'new_project_matches': newProjectMatches,
      if (paymentReceived != null) 'payment_received': paymentReceived,
      if (qualityScoreAlerts != null) 'quality_score_alerts': qualityScoreAlerts,
      if (bidStatusUpdates != null) 'bid_status_updates': bidStatusUpdates,
    };
  }
}

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? country;
  final String? city;
  final String? state;
  final String? bio;
  final String? profilePicture;
  final String? avatarUrl;
  final String role;
  final NotificationSettings? notificationSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Contractor specific fields
  final String? companyName;
  final int? completedProjectsCount;
  final String? successRate;
  final String? averageQualityScore;
  final String? responseTime;
  final List<String>? skills;
  final List<String>? serviceAreas;
  final Map<String, String>? verificationStatuses;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.country,
    this.city,
    this.state,
    this.bio,
    this.profilePicture,
    this.avatarUrl,
    required this.role,
    this.notificationSettings,
    required this.createdAt,
    required this.updatedAt,
    this.companyName,
    this.completedProjectsCount,
    this.successRate,
    this.averageQualityScore,
    this.responseTime,
    this.skills,
    this.serviceAreas,
    this.verificationStatuses,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      bio: json['bio']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      role: json['role']?.toString() ?? '',
      notificationSettings: json['notification_settings'] != null
          ? NotificationSettings.fromJson(json['notification_settings'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
      companyName: json['company_name']?.toString(),
      completedProjectsCount: json['completed_projects_count'] as int?,
      successRate: json['success_rate']?.toString(),
      averageQualityScore: json['average_quality_score']?.toString(),
      responseTime: json['response_time']?.toString(),
      skills: json['skills'] != null ? List<String>.from(json['skills'] as List) : null,
      serviceAreas: json['service_areas'] != null ? List<String>.from(json['service_areas'] as List) : null,
      verificationStatuses: json['verification_statuses'] != null 
          ? Map<String, String>.from(json['verification_statuses'] as Map) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'country': country,
      'city': city,
      'state': state,
      'bio': bio,
      'profile_picture': profilePicture,
      'avatar_url': avatarUrl,
      'role': role,
      'notification_settings': notificationSettings?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'company_name': companyName,
      'completed_projects_count': completedProjectsCount,
      'success_rate': successRate,
      'average_quality_score': averageQualityScore,
      'response_time': responseTime,
      'skills': skills,
      'service_areas': serviceAreas,
      'verification_statuses': verificationStatuses,
    };
  }
}

class UpdateProfilePayload {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? country;
  final String? city;
  final String? state;
  final String? bio;

  UpdateProfilePayload({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.country,
    this.city,
    this.state,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (country != null) data['country'] = country;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (bio != null) data['bio'] = bio;
    return data;
  }
}

class ChangePasswordPayload {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ChangePasswordPayload({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    };
  }
}
