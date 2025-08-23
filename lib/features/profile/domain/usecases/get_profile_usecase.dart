import 'package:dartz/dartz.dart';
import 'package:jaidem/features/profile/domain/entities/user_entity.dart';
import 'package:jaidem/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUsecase {
  final ProfileRepository profileRepository;

  GetProfileUsecase({required this.profileRepository});

  Future<Either<String, UserEntity>> call() async {
    return await profileRepository.getUserProfile();
  }
}
