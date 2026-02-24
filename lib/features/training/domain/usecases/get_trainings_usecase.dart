import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/training/data/datasources/training_remote_datasource.dart';
import 'package:jaidem/features/training/data/models/training_model.dart';

class GetTrainingsUsecase {
  final TrainingRemoteDatasource repository;

  GetTrainingsUsecase(this.repository);

  Future<Either<String, ResponseModel<TrainingModel>>> call() {
    return repository.getTrainings();
  }
}

class GetTrainingByIdUsecase {
  final TrainingRemoteDatasource repository;

  GetTrainingByIdUsecase(this.repository);

  Future<Either<String, TrainingModel>> call(int id) {
    return repository.getTrainingById(id);
  }
}

class GetTrainingAnswersUsecase {
  final TrainingRemoteDatasource repository;

  GetTrainingAnswersUsecase(this.repository);

  Future<Either<String, List<TrainingAnswer>>> call({
    required int trainingId,
    required String authorId,
  }) {
    return repository.getTrainingAnswers(
      trainingId: trainingId,
      authorId: authorId,
    );
  }
}

class GetNPSQuestionsUsecase {
  final TrainingRemoteDatasource repository;

  GetNPSQuestionsUsecase(this.repository);

  Future<Either<String, List<NPSQuestion>>> call() {
    return repository.getNPSQuestions();
  }
}

class SubmitTrainingAnswerUsecase {
  final TrainingRemoteDatasource repository;

  SubmitTrainingAnswerUsecase(this.repository);

  Future<Either<String, TrainingAnswer>> call({
    required int rate,
    required String comment,
    required String author,
    required int training,
    required int question,
  }) {
    return repository.submitTrainingAnswer(
      rate: rate,
      comment: comment,
      author: author,
      training: training,
      question: question,
    );
  }
}
