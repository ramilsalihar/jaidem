import 'package:dartz/dartz.dart';
import 'package:jaidem/features/menu/data/models/message_model.dart';
import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class GetMessagesUseCase {
  final MenuRepository repository;

  GetMessagesUseCase(this.repository);

  Stream<Either<String, List<MessageModel>>> call(
      String chatId, String chatType) {
    return repository.getMessages(chatId, chatType);
  }
}
