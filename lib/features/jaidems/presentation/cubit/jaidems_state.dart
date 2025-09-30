part of 'jaidems_cubit.dart';

abstract class JaidemsState extends Equatable {
  const JaidemsState();

  @override
  List<Object?> get props => [];
}

class JaidemsInitial extends JaidemsState {}

class JaidemsLoading extends JaidemsState {}

class JaidemsLoaded extends JaidemsState {
  final ResponseModel<PersonModel> response;

  const JaidemsLoaded({required this.response});

  @override
  List<Object?> get props => [response];
}

class JaidemsError extends JaidemsState {
  final String message;

  const JaidemsError({required this.message});

  @override
  List<Object?> get props => [message];
}
