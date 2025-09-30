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
  final Map<String, String?> filters;

  const JaidemsLoaded({
    required this.response,
    this.filters = const {},
  });

  @override
  List<Object?> get props => [response, filters];
}

class JaidemsError extends JaidemsState {
  final String message;

  const JaidemsError({required this.message});

  @override
  List<Object?> get props => [message];
}
