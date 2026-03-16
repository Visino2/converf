class InviteMemberPayload {
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? projectId;
  final String? country;

  InviteMemberPayload({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.projectId,
    this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      if (projectId != null) 'project_id': projectId,
      if (country != null) 'country': country,
    };
  }
}
