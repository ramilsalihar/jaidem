import 'package:dartz/dartz.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:jaidem/features/menu/data/models/file_model.dart';

class GetFilesUsecase {
  final MenuRemoteDatasource repository;

  GetFilesUsecase(this.repository);

  Future<Either<String, ResponseModel<FileModel>>> call() {
    return repository.getFiles();
  }
}
