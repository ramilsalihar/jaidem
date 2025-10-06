import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class GetChatWithUserUseCase {
  final MenuRepository repository;

  GetChatWithUserUseCase(this.repository);

  Future<ChatModel?> call(String userId) async {
    final result = await repository.getChatWithUser(userId);
    return result.fold(
      (error) => throw Exception(error),
      (chat) => chat,
    );
  }
}
