import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/models/response_model.dart';
import 'package:jaidem/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:jaidem/features/menu/data/models/division_model.dart';
import 'package:jaidem/features/menu/data/models/file_model.dart';
import 'package:jaidem/features/menu/domain/usecases/get_files_usecase.dart';

part 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit({
    required this.signOutUsecase,
    required this.getFilesUsecase,
    required this.getDivisionsUsecase,
  }) : super(const MenuInitial());

  final SignOutUsecase signOutUsecase;
  final GetFilesUsecase getFilesUsecase;
  final GetDivisionsUsecase getDivisionsUsecase;

  bool _isUserLoggedIn = false;
  ResponseModel<FileModel>? _files;
  ResponseModel<Division>? _divisions;
  int? _selectedDivisionId;

  bool get isUserLoggedIn => _isUserLoggedIn;
  ResponseModel<FileModel>? get files => _files;
  ResponseModel<Division>? get divisions => _divisions;
  int? get selectedDivisionId => _selectedDivisionId;

  void initialize({required bool isUserLoggedIn}) async {
    _isUserLoggedIn = isUserLoggedIn;
    emit(MenuLoading(isUserLoggedIn: _isUserLoggedIn));

    await fetchDivisions();
    await fetchFiles();
  }

  /// fetch divisions from backend
  Future<void> fetchDivisions() async {
    final result = await getDivisionsUsecase.call();

    result.fold(
      (error) {
        // Silently handle error for divisions
      },
      (response) {
        _divisions = response;
      },
    );
  }

  /// fetch files from backend
  Future<void> fetchFiles({int? divisionId}) async {
    _selectedDivisionId = divisionId;
    emit(MenuLoading(
      isUserLoggedIn: _isUserLoggedIn,
      files: _files,
      divisions: _divisions,
      selectedDivisionId: _selectedDivisionId,
    ));

    final result = await getFilesUsecase.call(divisionId: divisionId);

    result.fold(
      (error) {
        emit(MenuError(
          message: error,
          isUserLoggedIn: _isUserLoggedIn,
          files: _files,
          divisions: _divisions,
          selectedDivisionId: _selectedDivisionId,
        ));
      },
      (response) {
        _files = response;

        emit(MenuLoaded(
          isUserLoggedIn: _isUserLoggedIn,
          files: _files!,
          divisions: _divisions,
          selectedDivisionId: _selectedDivisionId,
        ));
      },
    );
  }

  void selectDivision(int? divisionId) {
    fetchFiles(divisionId: divisionId);
  }

  void updateLoginStatus({required bool isLoggedIn}) {
    _isUserLoggedIn = isLoggedIn;

    emit(MenuLoaded(
      isUserLoggedIn: _isUserLoggedIn,
      files: _files ?? ResponseModel(count: 0, results: []),
      divisions: _divisions,
      selectedDivisionId: _selectedDivisionId,
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
        _divisions = null;
        _selectedDivisionId = null;
        emit(const MenuSignOutSuccess());
      },
    );
  }

  void reset() {
    _isUserLoggedIn = false;
    _files = null;
    _divisions = null;
    _selectedDivisionId = null;
    emit(const MenuInitial());
  }
}
