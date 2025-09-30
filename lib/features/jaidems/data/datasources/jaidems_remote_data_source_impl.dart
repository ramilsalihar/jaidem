import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/features/jaidems/data/datasources/jaidems_remote_data_source.dart';

class JaidemsRemoteDataSourceImpl implements JaidemsRemoteDataSource {
  final Dio dio;

  const JaidemsRemoteDataSourceImpl({required this.dio});

  @override
  Future<Either<String, ResponseModel<PersonModel>>> getJaidems() async {
    try {
      final response = await dio.get(ApiConst.profile);

      if (response.statusCode == 200 || response.statusCode == 201) {

        final data = ResponseModel.fromJson(
          response.data,
          PersonModel.fromJson,
        );

        return Right(data);
      } else {
        return Left('Failed to load users');
      }
    } catch (e) {
      return Left('Failed to load user profile');
    }
  }
}
