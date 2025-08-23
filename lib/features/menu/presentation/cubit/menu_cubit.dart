
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/auth/domain/usecases/sign_out_usecase.dart';

part 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  MenuCubit({required this.signOutUsecase}) : super(const MenuInitial());

  final SignOutUsecase signOutUsecase;
  bool _isUserLoggedIn = false;

  // Getter for current login status
  bool get isUserLoggedIn => _isUserLoggedIn;

  /// Initialize menu with user login status
  void initialize({required bool isUserLoggedIn}) {
    _isUserLoggedIn = isUserLoggedIn;
    emit(MenuLoaded(isUserLoggedIn: _isUserLoggedIn));
  }

  /// Update user login status
  void updateLoginStatus({required bool isLoggedIn}) {
    _isUserLoggedIn = isLoggedIn;
    emit(MenuLoaded(isUserLoggedIn: _isUserLoggedIn));
  }

  /// Sign out user using usecase
  Future<void> signOut() async {
    try {
      emit(MenuLoading(isUserLoggedIn: _isUserLoggedIn));
      
      final result = await signOutUsecase.call();
      
      result.fold(
        (failure) {
          emit(MenuError(
            message: failure.toString(),
            isUserLoggedIn: _isUserLoggedIn,
          ));
        },
        (success) {
          _isUserLoggedIn = false;
          emit(const MenuSignOutSuccess());
        },
      );
    } catch (e) {
      emit(MenuError(
        message: e.toString(),
        isUserLoggedIn: _isUserLoggedIn,
      ));
    }
  }

  /// Reset menu state
  void reset() {
    _isUserLoggedIn = false;
    emit(const MenuInitial());
  }
}
