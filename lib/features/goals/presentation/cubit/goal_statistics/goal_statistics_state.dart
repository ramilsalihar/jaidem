part of 'goal_statistics_cubit.dart';

abstract class GoalStatisticsState extends Equatable {
  const GoalStatisticsState();

  @override
  List<Object?> get props => [];
}

class GoalStatisticsInitial extends GoalStatisticsState {
  const GoalStatisticsInitial();
}

class GoalStatisticsLoading extends GoalStatisticsState {
  const GoalStatisticsLoading();
}

class GoalStatisticsLoaded extends GoalStatisticsState {
  final List<GoalTaskModel> allTasks;
  final Map<String, GoalIndicatorModel> indicatorMap;

  const GoalStatisticsLoaded({
    required this.allTasks,
    required this.indicatorMap,
  });

  @override
  List<Object?> get props => [allTasks, indicatorMap];
}

class GoalStatisticsError extends GoalStatisticsState {
  final String message;

  const GoalStatisticsError({required this.message});

  @override
  List<Object?> get props => [message];
}
