import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/profile/domain/usecases/get_profile_usecase.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this.getProfileUsecase}) : super(ProfileInitial());

  final GetProfileUsecase getProfileUsecase;
  dynamic _currentUser; // Store current user - replace with your User model type

  // Getter for current user
  dynamic get currentUser => _currentUser;

  /// Get user profile
  Future<void> getUser() async {
    try {
      emit(ProfileLoading());
      
      final result = await getProfileUsecase.call();
      
      result.fold(
        (failure) {
          emit(ProfileError(message: failure.toString()));
        },
        (user) {
          _currentUser = user;
          emit(ProfileLoaded(user: user));
        },
      );
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Update user profile
  Future<void> updateUser(dynamic updatedUserData) async {
    try {
      if (_currentUser == null) {
        emit(const ProfileError(message: 'No user data available'));
        return;
      }

      emit(ProfileUpdating(user: _currentUser));
      
      // TODO: Add your update user usecase here
      // final result = await updateProfileUsecase.call(updatedUserData);
      
      // For now, simulate the update
      await Future.delayed(const Duration(seconds: 1));
      
      // Update the current user with new data
      _currentUser = updatedUserData;
      emit(ProfileUpdated(user: _currentUser));
      
      // After successful update, emit loaded state
      emit(ProfileLoaded(user: _currentUser));
      
    } catch (e) {
      emit(ProfileError(message: e.toString()));
      // Restore previous state on error
      if (_currentUser != null) {
        emit(ProfileLoaded(user: _currentUser));
      }
    }
  }

  /// Remove current user (sign out)
  Future<void> signOut() async {
    try {
      // TODO: Add your sign out logic here (clear tokens, etc.)
      // await signOutUsecase.call();
      
      // Clear current user
      _currentUser = null;
      emit(ProfileSignedOut());
      
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    if (_currentUser != null) {
      await getUser();
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Reset to initial state
  void reset() {
    _currentUser = null;
    emit(ProfileInitial());
  }
}
