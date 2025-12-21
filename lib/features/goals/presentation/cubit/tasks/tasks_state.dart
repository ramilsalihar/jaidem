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
    super.goalTasks,
  });
}

class TasksLoaded extends TasksState {
  const TasksLoaded({
    required super.goalTasks,
  });
}

class TasksError extends TasksState {
  final String message;

  const TasksError({
    required this.message,
    required super.goalTasks,
  });

  @override
  List<Object> get props => [message, goalTasks];
}

class TaskCreating extends TasksState {
  const TaskCreating({
    required super.goalTasks,
  });
}

class TaskCreated extends TasksState {
  const TaskCreated({
    required super.goalTasks,
  });
}

class TaskCreationError extends TasksState {
  final String message;

  const TaskCreationError({
    required this.message,
    required super.goalTasks,
  });

  @override
  List<Object> get props => [message, goalTasks];
}

class TaskUpdating extends TasksState {
  const TaskUpdating({
    required super.goalTasks,
  });
}

class TaskUpdated extends TasksState {
  const TaskUpdated({
    required super.goalTasks,
  });
}

class TaskUpdateError extends TasksState {
  final String message;

  const TaskUpdateError({
    required this.message,
    required super.goalTasks,
  });

  @override
  List<Object> get props => [message, goalTasks];
}
