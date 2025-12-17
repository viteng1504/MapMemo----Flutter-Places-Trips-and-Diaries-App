import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/remote/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthApi api;

  AuthRepositoryImpl(this.api);

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await api.loginWithEmail(email: email, password: password);

    return user;
  }

  @override
  Future<void> register(String email, String username, String password) async {
    await api.registerWithEmail(
      email: email,
      username: username,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    await api.logout();
  }
}
