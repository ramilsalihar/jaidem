import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class SendMessageToUserUseCase {
  final MenuRepository repository;

  SendMessageToUserUseCase(this.repository);

  Future<void> call(String userId, String messageText, {String? photoUrl}) async {
    final result =
        await repository.sendMessageToUser(userId, messageText, photoUrl: photoUrl);
    result.fold(
      (error) => throw Exception(error),
      (_) => null,
    );
  }
}
