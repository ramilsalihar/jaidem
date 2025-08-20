import 'package:dartz/dartz.dart';
import 'package:jaidem/features/auth/domain/repositories/auth_repository.dart';

class SignOutUsecase {
  final AuthRepository _authRepository;

  SignOutUsecase(this._authRepository);

  Future<Either<String, void>> call() async {
    return await _authRepository.signOut();
  }
}
