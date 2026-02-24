import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/opros/data/models/opros_question_model.dart';
import 'package:jaidem/features/opros/data/models/opros_status_model.dart';

abstract class OprosRemoteDataSource {
  Future<Either<String, OprosStatusModel>> getOprosStatus();

  Future<Either<String, ResponseModel<OprosQuestionModel>>> getOprosQuestions({
    required String questionType,
    int page,
  });

  Future<Either<String, void>> submitOprosAnswers({
    required String surveyType,
    required List<Map<String, dynamic>> answers,
  });
}
