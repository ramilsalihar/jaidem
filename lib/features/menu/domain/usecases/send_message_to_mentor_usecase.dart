import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class SendMessageToMentorUseCase {
  final MenuRepository repository;

  SendMessageToMentorUseCase(this.repository);

  Future<void> call(String messageText) async {
    final result = await repository.sendMessageToMentor(messageText);
    result.fold(
      (error) => throw Exception(error),
      (_) => null,
    );
  }
}
