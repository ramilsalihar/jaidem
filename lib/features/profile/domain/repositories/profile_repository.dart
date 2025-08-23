import 'package:dartz/dartz.dart';
import 'package:jaidem/features/profile/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<Either<String, UserEntity>> getUserProfile();
}
