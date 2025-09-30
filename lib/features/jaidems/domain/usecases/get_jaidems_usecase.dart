import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/jaidems/data/datasources/jaidems_remote_data_source.dart';

class GetJaidemsUsecase {
  final JaidemsRemoteDataSource repository;

  const GetJaidemsUsecase(this.repository);

  Future<Either<String, ResponseModel<PersonModel>>> call() {
    return repository.getJaidems();
  }
}
