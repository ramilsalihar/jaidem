part of 'goals_cubit.dart';

abstract class GoalsState extends Equatable {
  final List<GoalModel> goals;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const GoalsState({
    this.goals = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  @override
  List<Object> get props => [goals, currentPage, hasMore, isLoadingMore];
}

class GoalsInitial extends GoalsState {
  const GoalsInitial() : super();
}

class GoalsLoading extends GoalsState {
  const GoalsLoading({
    required super.goals,
    super.currentPage,
    super.hasMore,
    super.isLoadingMore,
  });
}

class GoalsLoaded extends GoalsState {
  const GoalsLoaded({
    required super.goals,
    super.currentPage,
    super.hasMore,
    super.isLoadingMore,
  });
}

class GoalsError extends GoalsState {
  final String message;

  const GoalsError({
    required this.message,
    required super.goals,
    super.currentPage,
    super.hasMore,
  });

  @override
  List<Object> get props => [message, goals, currentPage, hasMore];
}

class GoalCreating extends GoalsState {
  const GoalCreating({
    required super.goals,
    super.currentPage,
    super.hasMore,
  });
}

class GoalCreated extends GoalsState {
  const GoalCreated({
    required super.goals,
    super.currentPage,
    super.hasMore,
  });
}

class GoalCreationError extends GoalsState {
  final String message;

  const GoalCreationError({
    required this.message,
    required super.goals,
    super.currentPage,
    super.hasMore,
  });

  @override
  List<Object> get props => [message, goals, currentPage, hasMore];
}

class GoalUpdating extends GoalsState {
  const GoalUpdating({
    required super.goals,
    super.currentPage,
    super.hasMore,
  });
}

class GoalUpdated extends GoalsState {
  const GoalUpdated({
    required super.goals,
    super.currentPage,
    super.hasMore,
  });
}

class GoalUpdateError extends GoalsState {
  final String message;

  const GoalUpdateError({
    required this.message,
    required super.goals,
    super.currentPage,
    super.hasMore,
  });

  @override
  List<Object> get props => [message, goals, currentPage, hasMore];
}

class GoalDeleting extends GoalsState {
  const GoalDeleting({
    required super.goals,
    super.currentPage,
    super.hasMore,
  });
}

class GoalDeleted extends GoalsState {
  const GoalDeleted({
    required super.goals,
    super.currentPage,
    super.hasMore,
  });
}

class GoalDeleteError extends GoalsState {
  final String message;

  const GoalDeleteError({
    required this.message,
    required super.goals,
    super.currentPage,
    super.hasMore,
  });

  @override
  List<Object> get props => [message, goals, currentPage, hasMore];
}
