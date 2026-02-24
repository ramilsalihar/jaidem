import 'package:dartz/dartz.dart';
import 'package:jaidem/features/birthday/data/datasources/birthday_remote_data_source.dart';
import 'package:jaidem/features/birthday/data/models/birthday_reaction_model.dart';
import 'package:jaidem/features/birthday/data/models/birthday_user_model.dart';
import 'package:jaidem/features/birthday/domain/repositories/birthday_repository.dart';

class BirthdayRepositoryImpl implements BirthdayRepository {
  final BirthdayRemoteDataSource remoteDataSource;

  BirthdayRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<BirthdayUserModel>>> getTodayBirthdays() {
    return remoteDataSource.getTodayBirthdays();
  }

  @override
  Future<Either<String, void>> sendReaction({
    required int toUserId,
    String emoji = '🎉',
  }) {
    return remoteDataSource.sendReaction(toUserId: toUserId, emoji: emoji);
  }

  @override
  Future<Either<String, BirthdayReactionsResponse>> getMyReactions() {
    return remoteDataSource.getMyReactions();
  }
}
