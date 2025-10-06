import 'package:jaidem/features/menu/data/models/chat_model.dart';
import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class GetChatWithMentorUseCase {
  final MenuRepository repository;

  GetChatWithMentorUseCase(this.repository);

  Future<ChatModel?> call() async {
    final result = await repository.getChatWithMentor();
    return result.fold(
      (error) => throw Exception(error),
      (chat) => chat,
    );
  }
}
