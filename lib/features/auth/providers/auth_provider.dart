import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_response.dart';
import '../models/contractor_register_request.dart';
import '../models/product_owner_register_request.dart';
import '../repositories/auth_repository.dart';
import '../../../core/auth/session_manager.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthResponse?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthResponse?> {
  @override
  Future<AuthResponse?> build() async {
    final sessionManager = ref.read(sessionManagerProvider);
    final token = await sessionManager.getToken();
    final user = await sessionManager.getUser();
    
    if (token != null && user != null) {
      return AuthResponse(
        status: true,
        message: 'Session restored',
        data: AuthData(token: token, user: user),
      );
    }
    return null;
  }

  Future<void> registerContractor(ContractorRegisterRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.registerContractor(request);
      
      if (response.status && response.data != null) {
        await ref.read(sessionManagerProvider).saveSession(
          response.data!.token,
          response.data!.user,
        );
      }
      return response;
    });
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.login(email, password);
      
      if (response.status && response.data != null) {
        await ref.read(sessionManagerProvider).saveSession(
          response.data!.token,
          response.data!.user,
        );
      }
      return response;
    });
  }

  Future<void> registerOwner(ProductOwnerRegisterRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.registerOwner(request);
      
      if (response.status && response.data != null) {
        await ref.read(sessionManagerProvider).saveSession(
          response.data!.token,
          response.data!.user,
        );
      }
      return response;
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      await ref.read(sessionManagerProvider).clearSession();
      return null;
    });
    state = const AsyncValue.data(null);
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.forgotPassword(email);
    });
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    });
  }

  Future<void> acceptInvitation({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.acceptInvitation(
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    });
  }
}
