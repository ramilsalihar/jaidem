part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String accessToken;

  const AuthAuthenticated({required this.accessToken});

  @override
  List<Object> get props => [accessToken];
}

class AuthUnauthenticated extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final String accessToken;

  const AuthLoginSuccess({required this.accessToken});

  @override
  List<Object> get props => [accessToken];
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
