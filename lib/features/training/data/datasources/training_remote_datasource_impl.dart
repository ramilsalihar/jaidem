import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/features/training/data/datasources/training_remote_datasource.dart';
import 'package:jaidem/features/training/data/models/training_model.dart';

class TrainingRemoteDatasourceImpl implements TrainingRemoteDatasource {
  final Dio dio;

  TrainingRemoteDatasourceImpl({required this.dio});

  @override
  Future<Either<String, ResponseModel<TrainingModel>>> getTrainings({int? flowId}) async {
    try {
      final response = await dio.get(
        ApiConst.trainings,
        queryParameters: {
          if (flowId != null) 'flow': flowId,
        },
      );

      if (response.statusCode == 200) {
        final data = ResponseModel<TrainingModel>.fromJson(
          response.data,
          (json) => TrainingModel.fromJson(json),
        );
        return Right(data);
      } else {
        return Left('Failed to fetch trainings. Status code: ${response.statusCode}');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, TrainingModel>> getTrainingById(int id) async {
    try {
      final response = await dio.get('${ApiConst.trainings}$id/');

      if (response.statusCode == 200) {
        final training = TrainingModel.fromJson(response.data);
        return Right(training);
      } else {
        return Left('Failed to fetch training. Status code: ${response.statusCode}');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<TrainingAnswer>>> getTrainingAnswers({
    required int trainingId,
    required String authorId,
  }) async {
    try {
      final response = await dio.get(
        ApiConst.trainingAnswers,
        queryParameters: {
          'training': trainingId,
          'author': authorId,
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List<dynamic>? ?? [];
        final answers = results
            .map((e) => TrainingAnswer.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(answers);
      } else {
        return Left('Failed to fetch answers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<NPSQuestion>>> getNPSQuestions() async {
    try {
      final response = await dio.get(ApiConst.npsQuestions);

      if (response.statusCode == 200) {
        final results = response.data['results'] as List<dynamic>? ?? [];
        final questions = results
            .map((e) => NPSQuestion.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(questions);
      } else {
        return Left('Failed to fetch questions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, TrainingAnswer>> submitTrainingAnswer({
    required int rate,
    required String comment,
    required String author,
    required int training,
    required int question,
  }) async {
    try {
      final response = await dio.post(
        ApiConst.trainingAnswers,
        data: {
          'rate': rate,
          'comment': comment,
          'author': author,
          'training': training,
          'question': question,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final answer = TrainingAnswer.fromJson(response.data);
        return Right(answer);
      } else {
        return Left('Failed to submit answer. Status code: ${response.statusCode}');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
