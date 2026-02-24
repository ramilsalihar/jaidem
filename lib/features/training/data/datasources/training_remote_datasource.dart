import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/training/data/models/training_model.dart';

abstract class TrainingRemoteDatasource {
  Future<Either<String, ResponseModel<TrainingModel>>> getTrainings();
  Future<Either<String, TrainingModel>> getTrainingById(int id);
  Future<Either<String, List<TrainingAnswer>>> getTrainingAnswers({
    required int trainingId,
    required String authorId,
  });
  Future<Either<String, List<NPSQuestion>>> getNPSQuestions();
  Future<Either<String, TrainingAnswer>> submitTrainingAnswer({
    required int rate,
    required String comment,
    required String author,
    required int training,
    required int question,
  });
}
