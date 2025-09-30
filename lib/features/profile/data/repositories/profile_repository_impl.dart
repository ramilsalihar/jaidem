import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/features/profile/data/datasources/remote/profile_remote_data_source.dart';

import 'package:jaidem/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, PersonModel>> getUserProfile() async {
    return remoteDataSource.getUserProfile();
  }
  
  @override
  Future<Either<String, String>> udpateUserProfile(PersonModel person) {
    return remoteDataSource.updateUserProfile(person);
  }
}
