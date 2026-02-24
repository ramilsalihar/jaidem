part of 'menu_cubit.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  // Base getters that subclasses override
  ResponseModel<Division>? get divisions => null;
  int? get selectedDivisionId => null;

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {
  const MenuInitial({
    this.isUserLoggedIn = false,
    this.files,
    this.divisions,
    this.selectedDivisionId,
  });

  final bool isUserLoggedIn;
  final ResponseModel<FileModel>? files;
  final ResponseModel<Division>? divisions;
  final int? selectedDivisionId;

  @override
  List<Object?> get props => [isUserLoggedIn, files, divisions, selectedDivisionId];
}

class MenuLoading extends MenuState {
  const MenuLoading({
    required this.isUserLoggedIn,
    this.files,
    this.divisions,
    this.selectedDivisionId,
  });

  final bool isUserLoggedIn;
  final ResponseModel<FileModel>? files;
  final ResponseModel<Division>? divisions;
  final int? selectedDivisionId;

  @override
  List<Object?> get props => [isUserLoggedIn, files, divisions, selectedDivisionId];
}

class MenuLoaded extends MenuState {
  const MenuLoaded({
    required this.isUserLoggedIn,
    required this.files,
    this.divisions,
    this.selectedDivisionId,
  });

  final bool isUserLoggedIn;
  final ResponseModel<FileModel> files;
  final ResponseModel<Division>? divisions;
  final int? selectedDivisionId;

  @override
  List<Object?> get props => [isUserLoggedIn, files, divisions, selectedDivisionId];
}

class MenuSignOutSuccess extends MenuState {
  const MenuSignOutSuccess()
      : isUserLoggedIn = false,
        files = null,
        divisions = null,
        selectedDivisionId = null;

  final bool isUserLoggedIn;
  final ResponseModel<FileModel>? files;
  final ResponseModel<Division>? divisions;
  final int? selectedDivisionId;

  @override
  List<Object?> get props => [isUserLoggedIn, files, divisions, selectedDivisionId];
}

class MenuError extends MenuState {
  const MenuError({
    required this.message,
    required this.isUserLoggedIn,
    this.files,
    this.divisions,
    this.selectedDivisionId,
  });

  final String message;
  final bool isUserLoggedIn;
  final ResponseModel<FileModel>? files;
  final ResponseModel<Division>? divisions;
  final int? selectedDivisionId;

  @override
  List<Object?> get props => [message, isUserLoggedIn, files, divisions, selectedDivisionId];
}
