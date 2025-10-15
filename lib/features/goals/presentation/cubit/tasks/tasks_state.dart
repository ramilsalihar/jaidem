part of 'tasks_cubit.dart';

abstract class TasksState extends Equatable {
  final Map<String, List<GoalTaskModel>> goalTasks;
  
  const TasksState({
    this.goalTasks = const {},
  });

  @override
  List<Object> get props => [goalTasks];
}

class TasksInitial extends TasksState {
  const TasksInitial() : super();
}

class TasksLoading extends TasksState {
  const TasksLoading({
    Map<String, List<GoalTaskModel>> goalTasks = const {},
  }) : super(goalTasks: goalTasks);
}

class TasksLoaded extends TasksState {
  const TasksLoaded({
    required Map<String, List<GoalTaskModel>> goalTasks,
  }) : super(goalTasks: goalTasks);
}

class TasksError extends TasksState {
  final String message;

  const TasksError({
    required this.message,
    required Map<String, List<GoalTaskModel>> goalTasks,
  }) : super(goalTasks: goalTasks);

  @override
  List<Object> get props => [message, goalTasks];
}

class TaskCreating extends TasksState {
  const TaskCreating({
    required Map<String, List<GoalTaskModel>> goalTasks,
  }) : super(goalTasks: goalTasks);
}

class TaskCreated extends TasksState {
  const TaskCreated({
    required Map<String, List<GoalTaskModel>> goalTasks,
  }) : super(goalTasks: goalTasks);
}

class TaskCreationError extends TasksState {
  final String message;

  const TaskCreationError({
    required this.message,
    required Map<String, List<GoalTaskModel>> goalTasks,
  }) : super(goalTasks: goalTasks);

  @override
  List<Object> get props => [message, goalTasks];
}

class TaskUpdating extends TasksState {
  const TaskUpdating({
    required Map<String, List<GoalTaskModel>> goalTasks,
  }) : super(goalTasks: goalTasks);
}

class TaskUpdated extends TasksState {
  const TaskUpdated({
    required Map<String, List<GoalTaskModel>> goalTasks,
  }) : super(goalTasks: goalTasks);
}

class TaskUpdateError extends TasksState {
  final String message;

  const TaskUpdateError({
    required this.message,
    required Map<String, List<GoalTaskModel>> goalTasks,
  }) : super(goalTasks: goalTasks);

  @override
  List<Object> get props => [message, goalTasks];
}
