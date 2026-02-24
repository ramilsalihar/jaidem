import 'package:dartz/dartz.dart';
import 'package:jaidem/features/opros/data/models/opros_question_model.dart';
import 'package:jaidem/features/opros/domain/repositories/opros_repository.dart';

class GetOprosQuestionsUseCase {
  final OprosRepository repository;

  const GetOprosQuestionsUseCase(this.repository);

  Future<Either<String, List<OprosQuestionModel>>> call({
    required String questionType,
  }) async {
    return await repository.getOprosQuestions(questionType: questionType);
  }
}
