import 'package:dartz/dartz.dart';
import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class MarkMessageAsReadUseCase {
  final MenuRepository repository;

  MarkMessageAsReadUseCase(this.repository);

  Future<Either<String, void>> call(
      String chatId, String messageId, String userId, String chatType) {
    return repository.markMessageAsRead(chatId, messageId, userId, chatType);
  }
}
