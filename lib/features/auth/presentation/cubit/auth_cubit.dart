import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/auth/domain/usecases/is_user_logged_in_usecase.dart';
import 'package:jaidem/features/auth/domain/usecases/login_usecase.dart';
import 'package:jaidem/features/auth/domain/usecases/sign_out_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUsecase loginUsecase;
  final SignOutUsecase signOutUsecase;
  final IsUserLoggedInUsecase isUserLoggedInUsecase;

  AuthCubit({
    required this.loginUsecase,
    required this.signOutUsecase,
    required this.isUserLoggedInUsecase,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    final result = await isUserLoggedInUsecase.call();

    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (isLoggedIn) {
        if (isLoggedIn) {
          emit(const AuthAuthenticated());
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  /// Login user with username and password
  Future<void> login(String username, String password) async {
    emit(AuthLoading());

    final result = await loginUsecase.call(username, password);

    result.fold(
      (failure) {
        emit(AuthLoginFailure(error: failure));
      },
      (success) {
        emit(const AuthAuthenticated());
      },
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    emit(AuthLoading());

    final result = await signOutUsecase.call();

    result.fold(
      (failure) {
        emit(AuthLogoutFailure(error: failure));
      },
      (_) {
        emit(AuthUnauthenticated());
      },
    );
  }

  /// Check if user is currently authenticated
  Future<void> isUserAuthenticated() async {
    final result = await isUserLoggedInUsecase.call();
    return result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (isLoggedIn) {
        if (isLoggedIn) {
          emit(AuthAuthenticated());
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }
}
