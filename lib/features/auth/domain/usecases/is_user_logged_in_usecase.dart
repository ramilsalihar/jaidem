import 'package:dartz/dartz.dart';
import 'package:jaidem/features/auth/domain/repositories/auth_repository.dart';

class IsUserLoggedInUsecase {
  final AuthRepository _authRepository;

  IsUserLoggedInUsecase(this._authRepository);

  Future<Either<String, bool>> call() async {
    return await _authRepository.isAuthenticated();
  }
}
