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
  const GoalsLoading({
    required super.goals,
  });
}

class GoalsLoaded extends GoalsState {
  const GoalsLoaded({
    required super.goals,
  });
}

class GoalsError extends GoalsState {
  final String message;

  const GoalsError({
    required this.message,
    required super.goals,
  });

  @override
  List<Object> get props => [message, goals];

}

class GoalCreating extends GoalsState {
  const GoalCreating({
    required super.goals,
  });
}

class GoalCreated extends GoalsState {
  const GoalCreated({
    required super.goals,
  });
}

class GoalCreationError extends GoalsState {
  final String message;

  const GoalCreationError({
    required this.message,
    required super.goals,
  });

  @override
  List<Object> get props => [message, goals];
}
