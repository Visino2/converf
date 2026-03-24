class ContractorProfile {
  final String id;
  final String companyName;
  final String businessRegistrationNumber;
  final int yearsInBusiness;
  final String licenseNumber;
  final String businessAddress;
  final String taxIdentificationNumber;
  final String verificationStatus;
  final double rating;
  final int totalProjectsCount;
  final List<String> specialisations;

  ContractorProfile({
    required this.id,
    required this.companyName,
    required this.businessRegistrationNumber,
    required this.yearsInBusiness,
    required this.licenseNumber,
    required this.businessAddress,
    required this.taxIdentificationNumber,
    required this.verificationStatus,
    required this.rating,
    required this.totalProjectsCount,
    required this.specialisations,
  });

  factory ContractorProfile.fromJson(Map<String, dynamic> json) {
    return ContractorProfile(
      id: json['id']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      businessRegistrationNumber: json['business_registration_number']?.toString() ?? '',
      yearsInBusiness: json['years_in_business'] as int? ?? 0,
      licenseNumber: json['license_number']?.toString() ?? '',
      businessAddress: json['business_address']?.toString() ?? '',
      taxIdentificationNumber: json['tax_identification_number']?.toString() ?? '',
      verificationStatus: json['verification_status']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalProjectsCount: json['total_projects_count'] as int? ?? 0,
      specialisations: (json['specialisations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class Contractor {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String companyName;
  final String? avatarUrl;
  final ContractorProfile profile;
  final String createdAt;

  Contractor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.companyName,
    this.avatarUrl,
    required this.profile,
    required this.createdAt,
  });

  factory Contractor.fromJson(Map<String, dynamic> json) {
    return Contractor(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      profile: ContractorProfile.fromJson(json['profile'] as Map<String, dynamic>? ?? {}),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  String get displayName => '$firstName $lastName';
}

class ContractorsResponse {
  final bool status;
  final String message;
  final List<Contractor> data;

  ContractorsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ContractorsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return ContractorsResponse(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: dataList.map((e) => Contractor.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
