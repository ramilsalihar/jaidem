part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.user});
  
  final dynamic user; // Replace with your User model type
  
  @override
  List<Object?> get props => [user];
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating({required this.user});
  
  final dynamic user; // Current user while updating
  
  @override
  List<Object?> get props => [user];
}

class ProfileUpdated extends ProfileState {
  const ProfileUpdated({required this.user});
  
  final dynamic user; // Updated user
  
  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  const ProfileError({required this.message});
  
  final String message;
  
  @override
  List<Object?> get props => [message];
}

class ProfileSignedOut extends ProfileState {}
