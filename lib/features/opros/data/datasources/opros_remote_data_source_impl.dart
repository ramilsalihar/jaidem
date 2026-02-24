import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/features/opros/data/datasources/opros_remote_data_source.dart';
import 'package:jaidem/features/opros/data/models/opros_question_model.dart';
import 'package:jaidem/features/opros/data/models/opros_status_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OprosRemoteDataSourceImpl implements OprosRemoteDataSource {
  final Dio dio;
  final SharedPreferences prefs;

  const OprosRemoteDataSourceImpl({required this.dio, required this.prefs});

  @override
  Future<Either<String, OprosStatusModel>> getOprosStatus() async {
    try {
      final response = await dio.get(ApiConst.oprosStatus);
      if ([200, 201].contains(response.statusCode)) {
        return Right(OprosStatusModel.fromJson(response.data));
      } else {
        return const Left('Failed to fetch opros status');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, ResponseModel<OprosQuestionModel>>> getOprosQuestions({
    required String questionType,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        ApiConst.oprosQuestions,
        queryParameters: {
          'question_type': questionType,
          'page': page,
        },
      );
      if ([200, 201].contains(response.statusCode)) {
        final responseModel = ResponseModel<OprosQuestionModel>.fromJson(
          response.data,
          (json) => OprosQuestionModel.fromJson(json),
        );
        return Right(responseModel);
      } else {
        return const Left('Failed to fetch opros questions');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, void>> submitOprosAnswers({
    required String surveyType,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final response = await dio.post(
        ApiConst.oprosAnswer,
        data: {
          'survey_type': surveyType,
          'answers': answers,
        },
      );
      if ([200, 201].contains(response.statusCode)) {
        return const Right(null);
      } else {
        return const Left('Failed to submit opros answers');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
