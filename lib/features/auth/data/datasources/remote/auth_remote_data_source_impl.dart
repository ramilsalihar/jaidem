import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/network/network_info.dart';
import 'package:jaidem/core/network/exceptions.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:jaidem/features/auth/data/models/tokens_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final NetworkInfo networkInfo;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.networkInfo,
  });

  @override
  Future<Either<String, TokensModel>> getRefreshToken() {
    // TODO: implement getRefreshToken
    throw UnimplementedError();
  }

  @override
  Future<Either<String, bool>> isAuthenticated() {
    // TODO: implement isAuthenticated
    throw UnimplementedError();
  }

  @override
  Future<Either<String, TokensModel>> login(
      String username, String password) async {
    return _makeNetworkCall<TokensModel>(() async {
      final response = await dio.post(
        ApiConst.login,
        data: {'login': username, 'password': password},
      );

      if ([200, 201].contains(response.statusCode)) {
        return TokensModel.fromJson(response.data);
      } else {
        throw Exception('Login failed');
      }
    });
  }

  Future<Either<String, T>> _makeNetworkCall<T>(
    Future<T> Function() networkCall,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left('Нет подключения к интернету');
    }

    try {
      final result = await networkCall();
      return Right(result);
    } on DioException catch (e) {
      return Left(ExceptionHandler.handleDioException(e));
    } catch (e) {
      return Left(ExceptionHandler.handleGeneralException(e));
    }
  }
}
