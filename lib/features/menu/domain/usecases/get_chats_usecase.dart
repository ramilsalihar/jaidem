import 'package:dartz/dartz.dart';
import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class GetChatsUseCase {
  final MenuRepository repository;

  GetChatsUseCase(this.repository);

  Stream<Either<String, List<ChatModel>>> call(String userId) {
    return repository.getChats(userId);
  }
}
