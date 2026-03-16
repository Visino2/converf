class ContractorRegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final String companyName;
  final String businessRegistrationNumber;
  final int yearsInBusiness;
  final String licenseNumber;
  final List<String> constructionSpecialisations;
  final String businessAddress;
  final String taxIdentificationNumber;
  final bool agreedToTerms;
  final bool confirmedInformationAccuracy;
  final String password;
  final String passwordConfirmation;

  ContractorRegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
    required this.companyName,
    required this.businessRegistrationNumber,
    required this.yearsInBusiness,
    required this.licenseNumber,
    required this.constructionSpecialisations,
    required this.businessAddress,
    required this.taxIdentificationNumber,
    required this.agreedToTerms,
    required this.confirmedInformationAccuracy,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'country': country,
      'company_name': companyName,
      'business_registration_number': businessRegistrationNumber,
      'years_in_business': yearsInBusiness,
      'license_number': licenseNumber,
      'construction_specialisations': constructionSpecialisations,
      'business_address': businessAddress,
      'tax_identification_number': taxIdentificationNumber,
      'agreed_to_terms': agreedToTerms,
      'confirmed_information_accuracy': confirmedInformationAccuracy,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
