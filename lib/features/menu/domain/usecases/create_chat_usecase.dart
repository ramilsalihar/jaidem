import 'package:dartz/dartz.dart';
import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class CreateChatUsecase {
  final MenuRepository repository;

  const CreateChatUsecase(this.repository);

  Future<Either<String, ChatModel>> call({
    required String currentUserId,
    required String otherUserId,
  }) {
    return repository.createChat(
      currentUserId,
      otherUserId,
      
    );
  }
}
