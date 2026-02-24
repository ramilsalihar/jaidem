import 'package:dartz/dartz.dart';
import 'package:jaidem/features/opros/domain/repositories/opros_repository.dart';

class SubmitOprosAnswersUseCase {
  final OprosRepository repository;

  const SubmitOprosAnswersUseCase(this.repository);

  Future<Either<String, void>> call({
    required String surveyType,
    required List<Map<String, dynamic>> answers,
  }) async {
    return await repository.submitOprosAnswers(
      surveyType: surveyType,
      answers: answers,
    );
  }
}
