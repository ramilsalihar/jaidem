part of 'menu_cubit.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {
  const MenuInitial({this.isUserLoggedIn = false, this.files});

  final bool isUserLoggedIn;
  final ResponseModel<FileModel>? files;

  @override
  List<Object?> get props => [isUserLoggedIn, files];
}

class MenuLoading extends MenuState {
  const MenuLoading({required this.isUserLoggedIn, this.files});

  final bool isUserLoggedIn;
  final ResponseModel<FileModel>? files;

  @override
  List<Object?> get props => [isUserLoggedIn, files];
}

class MenuLoaded extends MenuState {
  const MenuLoaded({required this.isUserLoggedIn, required this.files});

  final bool isUserLoggedIn;
  final ResponseModel<FileModel> files;

  @override
  List<Object?> get props => [isUserLoggedIn, files];
}

class MenuSignOutSuccess extends MenuState {
  const MenuSignOutSuccess()
      : isUserLoggedIn = false,
        files = null;

  final bool isUserLoggedIn;
  final ResponseModel<FileModel>? files;

  @override
  List<Object?> get props => [isUserLoggedIn, files];
}

class MenuError extends MenuState {
  const MenuError({
    required this.message,
    required this.isUserLoggedIn,
    this.files,
  });

  final String message;
  final bool isUserLoggedIn;
  final ResponseModel<FileModel>? files;

  @override
  List<Object?> get props => [message, isUserLoggedIn, files];
}
