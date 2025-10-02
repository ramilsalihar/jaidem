import 'package:dartz/dartz.dart';
import 'package:jaidem/features/menu/data/models/chat_user_model.dart';
import 'package:jaidem/features/menu/domain/repositories/menu_repository.dart';

class GetUsersUseCase {
  final MenuRepository repository;

  GetUsersUseCase(this.repository);

  Stream<Either<String, List<ChatUserModel>>> call() {
    return repository.getUsers();
  }
}
