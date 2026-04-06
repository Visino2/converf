import 'auth_response.dart';

enum SocialAuthMethod {
  google('google', 'Google'),
  apple('apple', 'Apple');

  const SocialAuthMethod(this.pathSegment, this.displayName);

  final String pathSegment;
  final String displayName;

  String get authPath => '/api/v1/auth/$pathSegment';
  String get tokenExchangePath => '/api/v1/auth/$pathSegment/token';

  static SocialAuthMethod? fromUri(Uri uri) {
    final normalizedPath = uri.path.toLowerCase();
    for (final method in values) {
      if (normalizedPath.contains('/${method.pathSegment}')) {
        return method;
      }
    }
    return null;
  }
}

extension SocialAuthRoleQuery on UserRole {
  String get socialAuthQueryValue {
    switch (this) {
      case UserRole.contractor:
        return 'contractor';
      case UserRole.projectOwner:
      case UserRole.unknown:
        return 'project_owner';
    }
  }
}

UserRole? userRoleFromOnboardingSelection(String? selection) {
  switch (selection) {
    case 'contractor':
      return UserRole.contractor;
    case 'project_owner':
    case 'owner':
      return UserRole.projectOwner;
    default:
      return null;
  }
}
