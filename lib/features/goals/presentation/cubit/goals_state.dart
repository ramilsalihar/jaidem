part of 'goals_cubit.dart';

abstract class GoalsState extends Equatable {
  final List<GoalModel> goals;
  
  const GoalsState({
    this.goals = const [],
  });

  @override
  List<Object> get props => [goals];
}

class GoalsInitial extends GoalsState {
  const GoalsInitial() : super();
}

class GoalsLoading extends GoalsState {
  const GoalsLoading({required List<GoalModel> goals}) : super(goals: goals);
}

class GoalsLoaded extends GoalsState {
  const GoalsLoaded({required List<GoalModel> goals}) : super(goals: goals);
}

class GoalsError extends GoalsState {
  final String message;

  const GoalsError({
    required this.message,
    required List<GoalModel> goals,
  }) : super(goals: goals);

  @override
  List<Object> get props => [message, goals];
}

class GoalCreating extends GoalsState {
  const GoalCreating({required List<GoalModel> goals}) : super(goals: goals);
}

class GoalCreated extends GoalsState {
  const GoalCreated({required List<GoalModel> goals}) : super(goals: goals);
}

class GoalCreationError extends GoalsState {
  final String message;

  const GoalCreationError({
    required this.message,
    required List<GoalModel> goals,
  }) : super(goals: goals);

  @override
  List<Object> get props => [message, goals];
}
