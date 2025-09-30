import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:jaidem/features/profile/domain/usecases/update_profile_usecase.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.getProfileUsecase,
    required this.updateProfileUsecase,
  }) : super(ProfileInitial());

  final GetProfileUsecase getProfileUsecase;
  final UpdateProfileUsecase updateProfileUsecase;

  PersonModel? _currentUser;

  PersonModel? get currentUser => _currentUser;

  /// Get user profile
  Future<void> getUser() async {
    try {
      emit(ProfileLoading());

      final result = await getProfileUsecase.call();

      result.fold(
        (failure) => emit(ProfileError(message: failure.toString())),
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
  /// Update user profile
  Future<void> updateUser(PersonModel updatedUserData) async {
    try {
      if (_currentUser == null) {
        emit(const ProfileError(message: 'No user data available'));
        return;
      }

      emit(ProfileUpdating(user: _currentUser!));

      final result = await updateProfileUsecase.call(updatedUserData);

      result.fold(
        (failure) {
          emit(ProfileError(message: failure.toString()));
          emit(ProfileLoaded(user: _currentUser!));
        },
        (_) async {
          await getUser();
          emit(ProfileLoaded(user: _currentUser!));
        },
      );
    } catch (e) {
      emit(ProfileError(message: e.toString()));
      if (_currentUser != null) {
        emit(ProfileLoaded(user: _currentUser!));
      }
    }
  }

  Future<void> signOut() async {
    try {
      _currentUser = null;
      emit(ProfileSignedOut());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> refreshUser() async {
    if (_currentUser != null) {
      await getUser();
    }
  }

  bool get isLoggedIn => _currentUser != null;

  void reset() {
    _currentUser = null;
    emit(ProfileInitial());
  }
}
