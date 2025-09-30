import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/data/models/response_model.dart';

abstract class JaidemsRemoteDataSource {
  Future<Either<String, ResponseModel<PersonModel>>> getJaidems();
}
