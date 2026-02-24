import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/data/models/goal_task_model.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goal_tasks_usecase.dart';

part 'goal_statistics_state.dart';

class GoalStatisticsCubit extends Cubit<GoalStatisticsState> {
  final FetchGoalTasksUseCase _fetchGoalTasksUseCase;

  GoalStatisticsCubit({
    required FetchGoalTasksUseCase fetchGoalTasksUseCase,
  })  : _fetchGoalTasksUseCase = fetchGoalTasksUseCase,
        super(const GoalStatisticsInitial());

  /// Fetches tasks for ALL indicators of a goal and aggregates them.
  Future<void> loadStatistics({
    required List<GoalIndicatorModel> indicators,
  }) async {
    emit(const GoalStatisticsLoading());

    final List<GoalTaskModel> allTasks = [];
    final Map<String, GoalIndicatorModel> indicatorMap = {};

    final validIndicators =
        indicators.where((i) => i.id != null).toList();

    // Fetch tasks for all indicators in parallel
    final futures = validIndicators.map((indicator) async {
      final indicatorId = indicator.id.toString();
      indicatorMap[indicatorId] = indicator;

      final result = await _fetchGoalTasksUseCase(indicatorId);
      result.fold(
        (_) {}, // Skip errors for individual indicators
        (responseModel) => allTasks.addAll(responseModel.results),
      );
    });

    await Future.wait(futures);

    emit(GoalStatisticsLoaded(
      allTasks: allTasks,
      indicatorMap: indicatorMap,
    ));
  }
}
