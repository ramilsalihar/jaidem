part of 'opros_cubit.dart';

abstract class OprosState extends Equatable {
  const OprosState();

  @override
  List<Object?> get props => [];
}

class OprosInitial extends OprosState {
  const OprosInitial();
}

// Status states
class OprosStatusLoading extends OprosState {
  const OprosStatusLoading();
}

class OprosStatusLoaded extends OprosState {
  final OprosStatusModel status;

  const OprosStatusLoaded({required this.status});

  @override
  List<Object?> get props => [status];
}

class OprosStatusError extends OprosState {
  final String message;

  const OprosStatusError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Questions states
class OprosQuestionsLoading extends OprosState {
  const OprosQuestionsLoading();
}

class OprosQuestionsLoaded extends OprosState {
  final List<OprosQuestionModel> questions;

  const OprosQuestionsLoaded({required this.questions});

  @override
  List<Object?> get props => [questions];
}

class OprosQuestionsError extends OprosState {
  final String message;

  const OprosQuestionsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Submit states
class OprosSubmitting extends OprosState {
  const OprosSubmitting();
}

class OprosSubmitSuccess extends OprosState {
  const OprosSubmitSuccess();
}

class OprosSubmitError extends OprosState {
  final String message;

  const OprosSubmitError({required this.message});

  @override
  List<Object?> get props => [message];
}
