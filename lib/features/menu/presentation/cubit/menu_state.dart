part of 'menu_cubit.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {
  const MenuInitial({this.isUserLoggedIn = false});
  
  final bool isUserLoggedIn;
  
  @override
  List<Object?> get props => [isUserLoggedIn];
}

class MenuLoading extends MenuState {
  const MenuLoading({required this.isUserLoggedIn});
  
  final bool isUserLoggedIn;
  
  @override
  List<Object?> get props => [isUserLoggedIn];
}

class MenuLoaded extends MenuState {
  const MenuLoaded({required this.isUserLoggedIn});
  
  final bool isUserLoggedIn;
  
  @override
  List<Object?> get props => [isUserLoggedIn];
}

class MenuSignOutSuccess extends MenuState {
  const MenuSignOutSuccess() : isUserLoggedIn = false;
  
  final bool isUserLoggedIn;
  
  @override
  List<Object?> get props => [isUserLoggedIn];
}

class MenuError extends MenuState {
  const MenuError({
    required this.message,
    required this.isUserLoggedIn,
  });
  
  final String message;
  final bool isUserLoggedIn;
  
  @override
  List<Object?> get props => [message, isUserLoggedIn];
}
