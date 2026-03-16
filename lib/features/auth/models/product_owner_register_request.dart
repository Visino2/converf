class ProductOwnerRegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final String password;
  final String passwordConfirmation;

  ProductOwnerRegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'country': country,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
