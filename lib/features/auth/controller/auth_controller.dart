import 'package:flutter_module_1/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/auth_repository.dart';

final authControllerProvider = Provider(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
  ),
);

class AuthController {
  final AuthRepository authRepository;
  AuthController({
    required this.authRepository,
  });

  Future<void> signInWithEmailandPassword({
    required String email,
    required String password,
  }) async {
    return authRepository.signInWithEmailandPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmailandPassword({
    required String email,
    required String password,
  }) async {
    return authRepository.signUpWithEmailandPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    return authRepository.signOut();
  }

  Future<void> storeUserInfoToFirebase(UserModel userModel) async {
    return authRepository.storeUserInfoToFirebase(userModel);
  }
}
