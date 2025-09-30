import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUsecase {
  final ProfileRepository profileRepository;

  UpdateProfileUsecase({required this.profileRepository});

  Future<Either<String, String>> call(PersonModel person) async {
    return await profileRepository.udpateUserProfile(person);
  }
}
