part of 'goals_cubit.dart';

abstract class GoalsState extends Equatable {
  final List<GoalModel> goals;
  final Map<String, List<GoalIndicatorModel>> goalIndicators;
  
  const GoalsState({
    this.goals = const [],
    this.goalIndicators = const {},
  });

  @override
  List<Object> get props => [goals, goalIndicators];
}

class GoalsInitial extends GoalsState {
  const GoalsInitial() : super();
}

class GoalsLoading extends GoalsState {
  const GoalsLoading({
    required List<GoalModel> goals,
    Map<String, List<GoalIndicatorModel>> goalIndicators = const {},
  }) : super(goals: goals, goalIndicators: goalIndicators);
}

class GoalsLoaded extends GoalsState {
  const GoalsLoaded({
    required List<GoalModel> goals,
    Map<String, List<GoalIndicatorModel>> goalIndicators = const {},
  }) : super(goals: goals, goalIndicators: goalIndicators);
}

class GoalsError extends GoalsState {
  final String message;

  const GoalsError({
    required this.message,
    required List<GoalModel> goals,
    Map<String, List<GoalIndicatorModel>> goalIndicators = const {},
  }) : super(goals: goals, goalIndicators: goalIndicators);

  @override
  List<Object> get props => [message, goals, goalIndicators];
}

class GoalCreating extends GoalsState {
  const GoalCreating({
    required List<GoalModel> goals,
    Map<String, List<GoalIndicatorModel>> goalIndicators = const {},
  }) : super(goals: goals, goalIndicators: goalIndicators);
}

class GoalCreated extends GoalsState {
  const GoalCreated({
    required List<GoalModel> goals,
    Map<String, List<GoalIndicatorModel>> goalIndicators = const {},
  }) : super(goals: goals, goalIndicators: goalIndicators);
}

class GoalCreationError extends GoalsState {
  final String message;

  const GoalCreationError({
    required this.message,
    required List<GoalModel> goals,
    Map<String, List<GoalIndicatorModel>> goalIndicators = const {},
  }) : super(goals: goals, goalIndicators: goalIndicators);

  @override
  List<Object> get props => [message, goals, goalIndicators];
}

// Goal Indicator States
class GoalIndicatorsLoading extends GoalsState {
  const GoalIndicatorsLoading({
    required List<GoalModel> goals,
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goals: goals, goalIndicators: goalIndicators);
}

class GoalIndicatorsLoaded extends GoalsState {
  const GoalIndicatorsLoaded({
    required List<GoalModel> goals,
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goals: goals, goalIndicators: goalIndicators);
}

class GoalIndicatorsError extends GoalsState {
  final String message;

  const GoalIndicatorsError({
    required this.message,
    required List<GoalModel> goals,
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goals: goals, goalIndicators: goalIndicators);

  @override
  List<Object> get props => [message, goals, goalIndicators];
}

class GoalIndicatorCreating extends GoalsState {
  const GoalIndicatorCreating({
    required List<GoalModel> goals,
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goals: goals, goalIndicators: goalIndicators);
}

class GoalIndicatorCreated extends GoalsState {
  const GoalIndicatorCreated({
    required List<GoalModel> goals,
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goals: goals, goalIndicators: goalIndicators);
}

class GoalIndicatorCreationError extends GoalsState {
  final String message;

  const GoalIndicatorCreationError({
    required this.message,
    required List<GoalModel> goals,
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goals: goals, goalIndicators: goalIndicators);

  @override
  List<Object> get props => [message, goals, goalIndicators];
}
