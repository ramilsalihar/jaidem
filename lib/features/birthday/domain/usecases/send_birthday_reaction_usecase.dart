import 'package:dartz/dartz.dart';
import 'package:jaidem/features/birthday/domain/repositories/birthday_repository.dart';

class SendBirthdayReactionUseCase {
  final BirthdayRepository repository;

  const SendBirthdayReactionUseCase(this.repository);

  Future<Either<String, void>> call({
    required int toUserId,
    String emoji = '🎉',
  }) async {
    return await repository.sendReaction(toUserId: toUserId, emoji: emoji);
  }
}
