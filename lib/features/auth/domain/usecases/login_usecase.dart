import 'package:dartz/dartz.dart';
import 'package:jaidem/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _authRepository;

  LoginUsecase(this._authRepository);

  Future<Either<String, void>> call(String username, String password) async {
    return await _authRepository.login(username, password);
  }
}
