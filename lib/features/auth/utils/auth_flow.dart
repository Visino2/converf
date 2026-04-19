import '../models/auth_response.dart';
import '../models/email_verification_status.dart';

const String splashRoute = '/';
const String onboardingRoute = '/onboarding';
const String ownerDashboardRoute = '/owner-dashboard';
const String contractorDashboardRoute = '/contractor-dashboard';
const String acceptInvitationRoute = '/accept-invitation';
const String verifyEmailRoute = '/auth/verify-email';

bool isAuthenticatedResponse(AuthResponse? response) {
  return response?.isAuthenticated ?? false;
}

bool isRootAuthPath(String path) {
  return path == splashRoute || path == onboardingRoute;
}

bool isVerifyEmailPath(String path) {
  return path == verifyEmailRoute || path.startsWith('/auth/email/verify/');
}

bool isAcceptInvitationPath(String path) {
  return path == acceptInvitationRoute;
}

bool isOwnerDashboardPath(String path) {
  return path == ownerDashboardRoute;
}

bool isContractorDashboardPath(String path) {
  return path == contractorDashboardRoute;
}

String? dashboardRouteForRole(UserRole role) {
  switch (role) {
    case UserRole.projectOwner:
      return ownerDashboardRoute;
    case UserRole.contractor:
      return contractorDashboardRoute;
    case UserRole.unknown:
      return null;
  }
}

String onboardingLocation({bool login = false}) {
  if (!login) {
    return onboardingRoute;
  }
  return '$onboardingRoute?${Uri(queryParameters: const {'mode': 'login'}).query}';
}

String acceptInvitationLocation({String? token}) {
  final trimmedToken = token?.trim() ?? '';
  if (trimmedToken.isEmpty) {
    return acceptInvitationRoute;
  }

  return '$acceptInvitationRoute?${Uri(queryParameters: {'token': trimmedToken}).query}';
}

String verifyEmailLocation({
  String? email,
  bool autoResend = false,
  String? verifyUrl,
  Map<String, String> queryParameters = const <String, String>{},
}) {
  final parameters = <String, String>{...queryParameters};

  if (email != null && email.trim().isNotEmpty) {
    parameters.putIfAbsent('email', () => email.trim());
  }
  if (verifyUrl != null && verifyUrl.trim().isNotEmpty) {
    parameters.putIfAbsent('verify_url', () => verifyUrl.trim());
  }
  if (autoResend) {
    parameters.putIfAbsent('auto_resend', () => '1');
  }

  if (parameters.isEmpty) {
    return verifyEmailRoute;
  }

  return '$verifyEmailRoute?${Uri(queryParameters: parameters).query}';
}

EmailVerificationStatus verificationStatusFromAuthResponse(
  AuthResponse? response,
) {
  return emailVerificationStatusFromPayload(response?.data?.user);
}
