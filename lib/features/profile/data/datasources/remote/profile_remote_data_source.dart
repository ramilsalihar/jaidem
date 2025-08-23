import 'package:dartz/dartz.dart';
import 'package:jaidem/features/profile/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<Either<String, UserModel>> getUserProfile();
}
