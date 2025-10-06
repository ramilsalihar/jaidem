import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class GetChatWithAdminUseCase {
  final MenuRepository repository;

  GetChatWithAdminUseCase(this.repository);

  Future<ChatModel?> call() async {
    final result = await repository.getChatWithAdmin();
    return result.fold(
      (error) => throw Exception(error),
      (chat) => chat,
    );
  }
}
