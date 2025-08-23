import 'package:dartz/dartz.dart';
import 'package:jaidem/features/profile/data/datasources/remote/profile_remote_data_source.dart';
import 'package:jaidem/features/profile/data/mappers/user_mappers.dart';
import 'package:jaidem/features/profile/domain/entities/user_entity.dart';
import 'package:jaidem/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, UserEntity>> getUserProfile() async {
    final result = await remoteDataSource.getUserProfile();
    return result.fold(
      (error) => Left(error),
      (user) {
        final userEntity = UserMapper.toEntity(user);
        return Right(userEntity);
      },
    );
  }
}
