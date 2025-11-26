import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repo;

  RegisterUsecase(this.repo);

  Future<void> call(String email, String password) {
    return repo.register(email, password);
  }
}
