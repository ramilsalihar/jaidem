import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/features/birthday/data/datasources/birthday_remote_data_source.dart';
import 'package:jaidem/features/birthday/data/models/birthday_reaction_model.dart';
import 'package:jaidem/features/birthday/data/models/birthday_user_model.dart';

class BirthdayRemoteDataSourceImpl implements BirthdayRemoteDataSource {
  final Dio dio;

  const BirthdayRemoteDataSourceImpl({required this.dio});

  @override
  Future<Either<String, List<BirthdayUserModel>>> getTodayBirthdays() async {
    try {
      final response = await dio.get(ApiConst.todayBirthdays);
      if ([200, 201].contains(response.statusCode)) {
        final list = (response.data as List<dynamic>)
            .map((e) =>
                BirthdayUserModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(list);
      } else {
        return const Left('Failed to fetch today birthdays');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, void>> sendReaction({
    required int toUserId,
    String emoji = '🎉',
  }) async {
    try {
      final response = await dio.post(
        ApiConst.birthdayReaction,
        data: {
          'to_user': toUserId,
          'emoji': emoji,
        },
      );
      if ([200, 201].contains(response.statusCode)) {
        return const Right(null);
      } else {
        return const Left('Failed to send birthday reaction');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, BirthdayReactionsResponse>> getMyReactions() async {
    try {
      final response = await dio.get(
        ApiConst.birthdayReaction,
        queryParameters: {'date': 'today'},
      );
      if ([200, 201].contains(response.statusCode)) {
        return Right(BirthdayReactionsResponse.fromJson(response.data));
      } else {
        return const Left('Failed to fetch birthday reactions');
      }
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
