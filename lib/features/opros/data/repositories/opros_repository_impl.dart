import 'package:dartz/dartz.dart';
import 'package:jaidem/features/opros/data/datasources/opros_remote_data_source.dart';
import 'package:jaidem/features/opros/data/models/opros_question_model.dart';
import 'package:jaidem/features/opros/data/models/opros_status_model.dart';
import 'package:jaidem/features/opros/domain/repositories/opros_repository.dart';

class OprosRepositoryImpl implements OprosRepository {
  final OprosRemoteDataSource remoteDataSource;

  OprosRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, OprosStatusModel>> getOprosStatus() {
    return remoteDataSource.getOprosStatus();
  }

  @override
  Future<Either<String, List<OprosQuestionModel>>> getOprosQuestions({
    required String questionType,
  }) {
    return remoteDataSource
        .getOprosQuestions(questionType: questionType)
        .then((result) {
      return result.fold(
        (failure) => Left(failure),
        (responseModel) => Right(responseModel.results),
      );
    });
  }

  @override
  Future<Either<String, void>> submitOprosAnswers({
    required String surveyType,
    required List<Map<String, dynamic>> answers,
  }) {
    return remoteDataSource.submitOprosAnswers(
      surveyType: surveyType,
      answers: answers,
    );
  }
}
