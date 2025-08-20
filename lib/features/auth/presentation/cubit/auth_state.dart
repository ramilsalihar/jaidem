part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {

  const AuthAuthenticated();

  @override
  List<Object> get props => [ ];
}

class AuthUnauthenticated extends AuthState {}

class AuthLoginSuccess extends AuthState {
  const AuthLoginSuccess();
}

class AuthLoginFailure extends AuthState {
  final String error;

  const AuthLoginFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class AuthLogoutSuccess extends AuthState {}

class AuthLogoutFailure extends AuthState {
  final String error;

  const AuthLogoutFailure({required this.error});

  @override
  List<Object> get props => [error];
}
