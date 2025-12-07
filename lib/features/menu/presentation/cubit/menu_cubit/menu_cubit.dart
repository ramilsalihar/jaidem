import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:jaidem/features/menu/data/models/file_model.dart';
import 'package:jaidem/features/menu/domain/usecases/get_files_usecase.dart';

part 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit({
    required this.signOutUsecase,
    required this.getFilesUsecase,
  }) : super(const MenuInitial());

  final SignOutUsecase signOutUsecase;
  final GetFilesUsecase getFilesUsecase;

  bool _isUserLoggedIn = false;
  ResponseModel<FileModel>? _files;

  bool get isUserLoggedIn => _isUserLoggedIn;
  ResponseModel<FileModel>? get files => _files;

  void initialize({required bool isUserLoggedIn}) async {
    _isUserLoggedIn = isUserLoggedIn;
    emit(MenuLoading(isUserLoggedIn: _isUserLoggedIn));

    await fetchFiles();
  }

  /// fetch files from backend
  Future<void> fetchFiles() async {
    emit(MenuLoading(isUserLoggedIn: _isUserLoggedIn, files: _files));

    final result = await getFilesUsecase.call();

    result.fold(
      (error) {
        emit(MenuError(
          message: error,
          isUserLoggedIn: _isUserLoggedIn,
          files: _files,
        ));
      },
      (response) {
        _files = response;

        emit(MenuLoaded(
          isUserLoggedIn: _isUserLoggedIn,
          files: _files!,
        ));
      },
    );
  }

  void updateLoginStatus({required bool isLoggedIn}) {
    _isUserLoggedIn = isLoggedIn;

    emit(MenuLoaded(
      isUserLoggedIn: _isUserLoggedIn,
      files: _files ?? ResponseModel(count: 0, results: []),
    ));
  }

  Future<void> signOut() async {
    emit(MenuLoading(isUserLoggedIn: _isUserLoggedIn, files: _files));

    final result = await signOutUsecase.call();

    result.fold(
      (failure) {
        emit(MenuError(
          message: failure.toString(),
          isUserLoggedIn: _isUserLoggedIn,
          files: _files,
        ));
      },
      (_) {
        _isUserLoggedIn = false;
        _files = null;
        emit(const MenuSignOutSuccess());
      },
    );
  }

  void reset() {
    _isUserLoggedIn = false;
    _files = null;
    emit(const MenuInitial());
  }
}
