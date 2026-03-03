import 'package:dartz/dartz.dart';
import 'package:jaidem/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:jaidem/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:jaidem/features/auth/data/models/tokens_model.dart';
import 'package:jaidem/features/auth/domain/repositories/auth_repository.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<String, String>> getAccessToken() async {
    try {
      final accessToken = await localDataSource.getAccessToken();

      if (accessToken != null &&
          accessToken.isNotEmpty &&
          !JwtDecoder.isExpired(accessToken)) {
        return Right(accessToken);
      }

      // Token is missing or expired — attempt refresh
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return const Left('Refresh token not found');
      }

      final refreshResult =
          await remoteDataSource.refreshAccessToken(refreshToken);

      return refreshResult.fold(
        (error) => Left(error),
        (newAccessToken) async {
          await localDataSource.saveToken(newAccessToken, null);
          return Right(newAccessToken);
        },
      );
    } catch (e) {
      return Left('Failed to get access token: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> isAuthenticated() async {
    try {
      final accessToken = await localDataSource.getAccessToken();
      final refreshToken = await localDataSource.getRefreshToken();

      // Check if both tokens exist and are not empty
      final hasValidTokens = accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty;

      return Right(hasValidTokens);
    } catch (e) {
      return Left('Failed to check login status: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, TokensModel>> login(
    String username,
    String password,
  ) async {
    return remoteDataSource.login(username, password).then((result) {
      return result.fold(
        (failure) => Left(failure),
        (tokensModel) async {
          await localDataSource.saveToken(
            tokensModel.accessToken,
            tokensModel.refreshToken,
          );

          await localDataSource.saveUsername(username);

          return Right(tokensModel);
        },
      );
    });
  }

  @override
  Future<Either<String, void>> signOut() async {
    return localDataSource.logout().then(
          (result) =>
              result ? const Right(null) : const Left('Failed to sign out'),
        );
  }
}
