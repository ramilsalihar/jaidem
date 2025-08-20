import 'package:dartz/dartz.dart';
import 'package:jaidem/features/auth/data/models/tokens_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<String, TokensModel>> login(String username, String password);

  Future<Either<String, TokensModel>> getRefreshToken();
}
