import 'package:dartz/dartz.dart';
import 'package:jaidem/features/birthday/data/models/birthday_reaction_model.dart';
import 'package:jaidem/features/birthday/domain/repositories/birthday_repository.dart';

class GetMyBirthdayReactionsUseCase {
  final BirthdayRepository repository;

  const GetMyBirthdayReactionsUseCase(this.repository);

  Future<Either<String, BirthdayReactionsResponse>> call() async {
    return await repository.getMyReactions();
  }
}
