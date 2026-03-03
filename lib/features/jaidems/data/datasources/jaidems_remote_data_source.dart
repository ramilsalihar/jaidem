import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/data/models/response_model.dart';

abstract class JaidemsRemoteDataSource {
  Future<Either<String, ResponseModel<PersonModel>>> getJaidems({
    String? next,
    String? previous,
    String? flow,
    String? generation,
    String? university,
    String? speciality,
    String? ageMin,
    String? ageMax,
    String? search,
    String? state,
    String? region,
    bool? isAdvisor,
  });

  Future<Either<String, PersonModel>> getJaidemById(int id);
}
