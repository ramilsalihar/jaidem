import 'package:dartz/dartz.dart';
import 'package:jaidem/features/birthday/data/models/birthday_user_model.dart';
import 'package:jaidem/features/birthday/domain/repositories/birthday_repository.dart';

class GetTodayBirthdaysUseCase {
  final BirthdayRepository repository;

  const GetTodayBirthdaysUseCase(this.repository);

  Future<Either<String, List<BirthdayUserModel>>> call() async {
    return await repository.getTodayBirthdays();
  }
}
