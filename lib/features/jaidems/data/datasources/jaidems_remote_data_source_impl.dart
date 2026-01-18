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
  Future<Either<String, ResponseModel<PersonModel>>> getJaidems({
    String? next,
    String? previous,
    String? flow,
    String? generation,
    String? university,
    String? speciality,
    String? age,
    String? search,
    String? region,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (next != null) queryParameters['next'] = next;
      if (previous != null) queryParameters['previous'] = previous;
      if (flow != null) queryParameters['flow'] = flow;
      if (generation != null) queryParameters['generation'] = generation;
      if (university != null) queryParameters['univer'] = university;
      if (speciality != null) queryParameters['speciality'] = speciality;
      if (age != null) queryParameters['age'] = age;
      if (search != null) queryParameters['search'] = search;
      if (region != null) queryParameters['region'] = region;

      final response = await dio.get(
        ApiConst.profile,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

  
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

  @override
  Future<Either<String, PersonModel>> getJaidemById(int id) async {
    try {
      final response = await dio.get('${ApiConst.profile}$id/');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final person = PersonModel.fromJson(response.data);
        return Right(person);
      } else {
        return const Left('Failed to load person');
      }
    } catch (e) {
      return Left('Failed to load person: $e');
    }
  }
}
