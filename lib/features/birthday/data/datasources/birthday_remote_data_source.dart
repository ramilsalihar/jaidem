import 'package:dartz/dartz.dart';
import 'package:jaidem/features/birthday/data/models/birthday_reaction_model.dart';
import 'package:jaidem/features/birthday/data/models/birthday_user_model.dart';

abstract class BirthdayRemoteDataSource {
  Future<Either<String, List<BirthdayUserModel>>> getTodayBirthdays();

  Future<Either<String, void>> sendReaction({
    required int toUserId,
    String emoji,
  });

  Future<Either<String, BirthdayReactionsResponse>> getMyReactions();
}
