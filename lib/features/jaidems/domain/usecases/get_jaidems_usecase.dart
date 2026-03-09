import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/jaidems/data/datasources/jaidems_remote_data_source.dart';

class GetJaidemsUsecase {
  final JaidemsRemoteDataSource repository;

  const GetJaidemsUsecase(this.repository);

  Future<Either<String, ResponseModel<PersonModel>>> call({
    String? next,
    String? previous,
    String? flow,
    String? generation,
    String? university,
    String? faculty,
    String? speciality,
    String? ageMin,
    String? ageMax,
    String? search,
    String? state,
    String? region,
    bool? isAdvisor,
  }) {
    return repository.getJaidems(
      next: next,
      previous: previous,
      flow: flow,
      generation: generation,
      university: university,
      faculty: faculty,
      speciality: speciality,
      ageMin: ageMin,
      ageMax: ageMax,
      search: search,
      state: state,
      region: region,
      isAdvisor: isAdvisor,
    );
  }

  Future<Either<String, PersonModel>> getById(int id) {
    return repository.getJaidemById(id);
  }
}
