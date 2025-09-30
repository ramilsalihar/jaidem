import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/data/models/jaidem/person_extension.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/profile/data/datasources/remote/profile_remote_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  final SharedPreferences prefs;

  ProfileRemoteDataSourceImpl({required this.dio, required this.prefs});

  @override
  Future<Either<String, PersonModel>> getUserProfile() async {
    try {
      final userId = prefs.getString(AppConstants.userId);

      final response = await dio.get('${ApiConst.profile}$userId/');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final userModel = PersonModel.fromJson(response.data);

        return Right(userModel);
      } else {
        return Left('Failed to load user profile');
      }
    } catch (e) {
      return Left('Failed to load user profile');
    }
  }

  @override
  Future<Either<String, String>> updateUserProfile(PersonModel person) async {
    try {
      final userId = prefs.getString(AppConstants.userId);

      final response = await dio.patch(
        '${ApiConst.profile}$userId/',
        data: person.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right('Updated Successfully!');
      } else {
        return Left('Failed to load user profile');
      }
    } catch (e) {
      return Left('Failed to load user profile');
    }
  }
}
