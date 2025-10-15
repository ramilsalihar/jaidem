import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/goals/data/models/goal_task_model.dart';
import 'package:jaidem/features/goals/domain/usecases/create_goal_task_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goal_tasks_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/update_goal_task_usecase.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final FetchGoalTasksUseCase _fetchGoalTasksUseCase;
  final CreateGoalTaskUseCase _createGoalTaskUseCase;
  final UpdateGoalTaskUsecase _updateGoalTaskUseCase;

  TasksCubit({
    required FetchGoalTasksUseCase fetchGoalTasksUseCase,
    required CreateGoalTaskUseCase createGoalTaskUseCase,
    required UpdateGoalTaskUsecase updateGoalTaskUseCase,
  })  : _fetchGoalTasksUseCase = fetchGoalTasksUseCase,
        _createGoalTaskUseCase = createGoalTaskUseCase,
        _updateGoalTaskUseCase = updateGoalTaskUseCase,
        super(const TasksInitial());

  Future<void> fetchGoalTasks(String indicatorId) async {
    emit(TasksLoading(goalTasks: state.goalTasks));

    final result = await _fetchGoalTasksUseCase(indicatorId);

    result.fold(
      (error) {
        emit(TasksError(
          message: error,
          goalTasks: state.goalTasks,
        ));
      },
      (responseModel) {
        final updatedTasks =
            Map<String, List<GoalTaskModel>>.from(state.goalTasks);
        // Sort tasks by most recent ID (assuming higher ID means more recent)
        final sortedTasks = List<GoalTaskModel>.from(responseModel.results)
          ..sort((a, b) {
            // Handle null IDs by putting them at the end
            if (a.id == null && b.id == null) return 0;
            if (a.id == null) return 1;
            if (b.id == null) return -1;
            return b.id!.compareTo(a.id!);
          });
        updatedTasks[indicatorId] = sortedTasks;
        emit(TasksLoaded(goalTasks: updatedTasks));
      },
    );
  }

  Future<void> createGoalTask(GoalTaskModel task) async {
    final indicatorId = task.indicatorIdString;

    emit(TaskCreating(goalTasks: state.goalTasks));

    final result = await _createGoalTaskUseCase(task);

    result.fold(
      (error) => emit(TaskCreationError(
        message: error,
        goalTasks: state.goalTasks,
      )),
      (newTask) {
        final updatedTasks =
            Map<String, List<GoalTaskModel>>.from(state.goalTasks);

        if (updatedTasks.containsKey(indicatorId)) {
          updatedTasks[indicatorId] =
              List<GoalTaskModel>.from(updatedTasks[indicatorId]!)
                ..insert(0, newTask);
        } else {
          updatedTasks[indicatorId] = [newTask];
        }

        emit(TaskCreated(goalTasks: updatedTasks));
      },
    );
  }

  Future<void> updateGoalTask(GoalTaskModel task) async {
    if (task.id == null) {
      emit(TaskUpdateError(
        message: 'Cannot update task without ID',
        goalTasks: state.goalTasks,
      ));
      return;
    }

    emit(TaskUpdating(goalTasks: state.goalTasks));

    final result = await _updateGoalTaskUseCase(task);

    result.fold(
      (error) => emit(TaskUpdateError(
        message: error,
        goalTasks: state.goalTasks,
      )),
      (updatedTask) {
        final updatedTasks =
            Map<String, List<GoalTaskModel>>.from(state.goalTasks);
        final indicatorId = updatedTask.indicatorIdString;

        if (updatedTasks.containsKey(indicatorId)) {
          final taskList = List<GoalTaskModel>.from(updatedTasks[indicatorId]!);
          final taskIndex = taskList.indexWhere((t) => t.id == updatedTask.id);

          if (taskIndex != -1) {
            taskList[taskIndex] = updatedTask;
            updatedTasks[indicatorId] = taskList;
          }
        }

        emit(TaskUpdated(goalTasks: updatedTasks));
      },
    );
  }
}
