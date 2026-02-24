part of 'training_cubit.dart';

abstract class TrainingState extends Equatable {
  const TrainingState();

  @override
  List<Object?> get props => [];
}

class TrainingInitial extends TrainingState {
  const TrainingInitial();
}

class TrainingLoading extends TrainingState {
  const TrainingLoading();
}

class TrainingLoaded extends TrainingState {
  final ResponseModel<TrainingModel> trainings;

  const TrainingLoaded({required this.trainings});

  @override
  List<Object?> get props => [trainings];
}

class TrainingError extends TrainingState {
  final String message;

  const TrainingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TrainingDetailLoading extends TrainingState {
  const TrainingDetailLoading();
}

class TrainingDetailLoaded extends TrainingState {
  final TrainingModel training;

  const TrainingDetailLoaded({required this.training});

  @override
  List<Object?> get props => [training];
}

class TrainingDetailError extends TrainingState {
  final String message;

  const TrainingDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Training Answers States
class TrainingAnswersLoading extends TrainingState {
  const TrainingAnswersLoading();
}

class TrainingAnswersLoaded extends TrainingState {
  final List<TrainingAnswer> answers;

  const TrainingAnswersLoaded({required this.answers});

  @override
  List<Object?> get props => [answers];
}

class TrainingAnswersError extends TrainingState {
  final String message;

  const TrainingAnswersError({required this.message});

  @override
  List<Object?> get props => [message];
}

// NPS Questions States
class NPSQuestionsLoading extends TrainingState {
  const NPSQuestionsLoading();
}

class NPSQuestionsLoaded extends TrainingState {
  final List<NPSQuestion> questions;

  const NPSQuestionsLoaded({required this.questions});

  @override
  List<Object?> get props => [questions];
}

class NPSQuestionsError extends TrainingState {
  final String message;

  const NPSQuestionsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Submit Answers States
class SubmittingAnswers extends TrainingState {
  const SubmittingAnswers();
}

class SubmitAnswersSuccess extends TrainingState {
  const SubmitAnswersSuccess();
}

class SubmitAnswersError extends TrainingState {
  final String message;

  const SubmitAnswersError({required this.message});

  @override
  List<Object?> get props => [message];
}
