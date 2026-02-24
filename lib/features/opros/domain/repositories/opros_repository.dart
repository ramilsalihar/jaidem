import 'package:dartz/dartz.dart';
import 'package:jaidem/features/opros/data/models/opros_question_model.dart';
import 'package:jaidem/features/opros/data/models/opros_status_model.dart';

abstract class OprosRepository {
  Future<Either<String, OprosStatusModel>> getOprosStatus();

  Future<Either<String, List<OprosQuestionModel>>> getOprosQuestions({
    required String questionType,
  });

  Future<Either<String, void>> submitOprosAnswers({
    required String surveyType,
    required List<Map<String, dynamic>> answers,
  });
}
