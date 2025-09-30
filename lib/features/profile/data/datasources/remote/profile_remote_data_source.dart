import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';

abstract class ProfileRemoteDataSource {
  Future<Either<String, PersonModel>> getUserProfile();

  Future<Either<String, String>> updateUserProfile(PersonModel person);
}
