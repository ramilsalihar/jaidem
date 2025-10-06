import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class SendMessageToAdminUseCase {
  final MenuRepository repository;

  SendMessageToAdminUseCase(this.repository);

  Future<void> call(String messageText) async {
    final result = await repository.sendMessageToAdmin(messageText);
    result.fold(
      (error) => throw Exception(error),
      (_) => null,
    );
  }
}
