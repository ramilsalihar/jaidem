import 'package:dartz/dartz.dart';
import 'package:jaidem/features/menu/data/models/message_model.dart';
import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class SendMessageUseCase {
  final MenuRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<String, void>> call(
      String chatId, String chatType, MessageModel message) {
    return repository.sendMessage(chatId, chatType, message);
  }
}
