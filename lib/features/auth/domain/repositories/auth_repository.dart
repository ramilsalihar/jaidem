import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<String, void>> login(String username, String password);

  Future<Either<String, bool>> isAuthenticated();

  Future<Either<String, String>> getAccessToken();

  Future<Either<String, void>> signOut();
}
