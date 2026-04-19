import '../../projects/models/project_image.dart';

class ContractorProfile {
  final String id;
  final String? companyName;
  final String? businessRegistrationNumber;
  final int? yearsInBusiness;
  final String? licenseNumber;
  final String? businessAddress;
  final String? taxIdentificationNumber;
  final String? verificationStatus;
  final String? verificationState;
  final double? rating;
  final int? totalProjectsCount;
  final List<String>? specialisations;
  final List<ContractorDocument>? documents;
  final List<ContractorCertification>? certifications;
  final List<ContractorPortfolioItem>? portfolio;

  ContractorProfile({
    required this.id,
    this.companyName,
    this.businessRegistrationNumber,
    this.yearsInBusiness,
    this.licenseNumber,
    this.businessAddress,
    this.taxIdentificationNumber,
    this.verificationStatus,
    this.verificationState,
    this.rating,
    this.totalProjectsCount,
    this.specialisations,
    this.documents,
    this.certifications,
    this.portfolio,
  });

  factory ContractorProfile.fromJson(Map<String, dynamic> json) {
    return ContractorProfile(
      id: json['id']?.toString() ?? '',
      companyName: json['company_name']?.toString(),
      businessRegistrationNumber:
          json['business_registration_number']?.toString(),
      yearsInBusiness: json['years_in_business'] == null
          ? null
          : int.tryParse(json['years_in_business'].toString()),
      licenseNumber: json['license_number']?.toString(),
      businessAddress: json['business_address']?.toString(),
      taxIdentificationNumber: json['tax_identification_number']?.toString(),
      verificationStatus: json['verification_status']?.toString(),
      verificationState: json['verification_state']?.toString(),
      rating: json['rating'] == null
          ? null
          : double.tryParse(json['rating'].toString()),
      totalProjectsCount: json['total_projects_count'] == null
          ? null
          : int.tryParse(json['total_projects_count'].toString()),
      specialisations: (json['specialisations'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      documents: (json['documents'] as List?)
          ?.whereType<Map>()
          .map((e) =>
              ContractorDocument.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      certifications: (json['certifications'] as List?)
          ?.whereType<Map>()
          .map((e) =>
              ContractorCertification.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      portfolio: (json['portfolio'] as List?)
          ?.whereType<Map>()
          .map((e) =>
              ContractorPortfolioItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (companyName != null) 'company_name': companyName,
      if (businessRegistrationNumber != null)
        'business_registration_number': businessRegistrationNumber,
      if (yearsInBusiness != null) 'years_in_business': yearsInBusiness,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (businessAddress != null) 'business_address': businessAddress,
      if (taxIdentificationNumber != null)
        'tax_identification_number': taxIdentificationNumber,
      if (verificationStatus != null) 'verification_status': verificationStatus,
      if (verificationState != null) 'verification_state': verificationState,
      if (rating != null) 'rating': rating,
      if (totalProjectsCount != null) 'total_projects_count': totalProjectsCount,
      if (specialisations != null) 'specialisations': specialisations,
    };
  }
}

class ContractorProfileResponse {
  final bool status;
  final String message;
  final ContractorProfile data;

  ContractorProfileResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ContractorProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return ContractorProfileResponse(
      status: json['status'] as bool? ?? true,
      message: json['message']?.toString() ?? '',
      data: ContractorProfile.fromJson(data),
    );
  }
}

class ContractorVerificationResponse {
  final String? verificationStatus;
  final List<Map<String, dynamic>>? steps;
  final List<ContractorDocument>? documents;

  ContractorVerificationResponse({
    this.verificationStatus,
    this.steps,
    this.documents,
  });

  factory ContractorVerificationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return ContractorVerificationResponse(
      verificationStatus: data['verification_status']?.toString(),
      steps: (data['steps'] as List?)
          ?.whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      documents: (data['documents'] as List?)
          ?.whereType<Map>()
          .map((e) => ContractorDocument.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class ContractorDocument {
  final String id;
  final String name;
  final String? url;
  final String? uploadedAt;

  ContractorDocument({
    required this.id,
    required this.name,
    this.url,
    this.uploadedAt,
  });

  factory ContractorDocument.fromJson(Map<String, dynamic> json) {
    return ContractorDocument(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['file_name']?.toString() ?? '',
      url: json['url']?.toString(),
      uploadedAt: json['uploaded_at']?.toString(),
    );
  }
}

class ContractorCertification {
  final String id;
  final String name;
  final String issuingBody;
  final String issuedAt;
  final String? expiresAt;

  ContractorCertification({
    required this.id,
    required this.name,
    required this.issuingBody,
    required this.issuedAt,
    this.expiresAt,
  });

  factory ContractorCertification.fromJson(Map<String, dynamic> json) {
    return ContractorCertification(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      issuingBody: json['issuing_body']?.toString() ?? '',
      issuedAt: json['issued_at']?.toString() ?? '',
      expiresAt: json['expires_at']?.toString(),
    );
  }
}

class ContractorPortfolioItem {
  final String id;
  final String title;
  final String? location;
  final String? city;
  final String? state;
  final String? country;
  final String? constructionType;
  final num? budget;
  final String? currency;
  final String? status;
  final String? startDate;
  final String? completedDate;
  final String? description;
  final String? coverImage;

  ContractorPortfolioItem({
    required this.id,
    required this.title,
    this.location,
    this.city,
    this.state,
    this.country,
    this.constructionType,
    this.budget,
    this.currency,
    this.status,
    this.startDate,
    this.completedDate,
    this.description,
    this.coverImage,
  });

  factory ContractorPortfolioItem.fromJson(Map<String, dynamic> json) {
    return ContractorPortfolioItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      constructionType: json['construction_type']?.toString(),
      budget: json['budget'] == null
          ? null
          : num.tryParse(json['budget'].toString()),
      currency: json['currency']?.toString(),
      status: json['status']?.toString(),
      startDate: json['start_date']?.toString(),
      completedDate: json['completed_date']?.toString(),
      description: json['description']?.toString(),
      coverImage: ProjectImage.normalizeImageUrl(json['cover_image']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (location != null) 'location': location,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (constructionType != null) 'construction_type': constructionType,
      if (budget != null) 'budget': budget,
      if (currency != null) 'currency': currency,
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate,
      if (completedDate != null) 'completed_date': completedDate,
      if (description != null) 'description': description,
      if (coverImage != null) 'cover_image': coverImage,
    };
  }
}

class ContractorPortfolioPayload {
  final String title;
  final String location;
  final String? city;
  final String? state;
  final String? country;
  final String? constructionType;
  final num? budget;
  final String? currency;
  final String? status; // 'completed' | 'ongoing'
  final String? startDate;
  final String? completedDate;
  final String? description;
  final dynamic coverImage; // Can be XFile or String (path)

  ContractorPortfolioPayload({
    required this.title,
    required this.location,
    this.city,
    this.state,
    this.country,
    this.constructionType,
    this.budget,
    this.currency,
    this.status,
    this.startDate,
    this.completedDate,
    this.description,
    this.coverImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'location': location,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (constructionType != null) 'construction_type': constructionType,
      if (budget != null) 'budget': budget,
      if (currency != null) 'currency': currency,
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate,
      if (completedDate != null) 'completed_date': completedDate,
      if (description != null) 'description': description,
    };
  }
}

class ContractorProfilePayload {
  final String? companyName;
  final String? businessRegistrationNumber;
  final int? yearsInBusiness;
  final String? licenseNumber;
  final String? businessAddress;
  final String? taxIdentificationNumber;
  final bool? agreedToTerms;
  final bool? confirmedInformationAccuracy;

  ContractorProfilePayload({
    this.companyName,
    this.businessRegistrationNumber,
    this.yearsInBusiness,
    this.licenseNumber,
    this.businessAddress,
    this.taxIdentificationNumber,
    this.agreedToTerms,
    this.confirmedInformationAccuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      if (companyName != null) 'company_name': companyName,
      if (businessRegistrationNumber != null)
        'business_registration_number': businessRegistrationNumber,
      if (yearsInBusiness != null) 'years_in_business': yearsInBusiness,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (businessAddress != null) 'business_address': businessAddress,
      if (taxIdentificationNumber != null)
        'tax_identification_number': taxIdentificationNumber,
      if (agreedToTerms != null) 'agreed_to_terms': agreedToTerms,
      if (confirmedInformationAccuracy != null)
        'confirmed_information_accuracy': confirmedInformationAccuracy,
    };
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
