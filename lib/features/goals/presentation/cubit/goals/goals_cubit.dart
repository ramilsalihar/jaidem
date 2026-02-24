import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/domain/usecases/create_goal_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goals_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/update_goal_usecase.dart';

part 'goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  final FetchGoalsUseCase _fetchGoalsUseCase;
  final CreateGoalUseCase _createGoalUseCase;
  final UpdateGoalUseCase _updateGoalUseCase;

  String? _selectedStatus;

  GoalsCubit({
    required FetchGoalsUseCase fetchGoalsUseCase,
    required CreateGoalUseCase createGoalUseCase,
    required UpdateGoalUseCase updateGoalUseCase,
  })  : _fetchGoalsUseCase = fetchGoalsUseCase,
        _createGoalUseCase = createGoalUseCase,
        _updateGoalUseCase = updateGoalUseCase,
        super(const GoalsInitial());

  Future<void> fetchGoals({bool refresh = false, String? status}) async {
    _selectedStatus = status;

    if (refresh) {
      emit(GoalsLoading(goals: const []));
    } else {
      emit(GoalsLoading(goals: state.goals));
    }

    final result = await _fetchGoalsUseCase(page: 1, status: _selectedStatus);

    result.fold(
      (error) => emit(GoalsError(message: error, goals: state.goals)),
      (response) {
        final hasMore = response.next != null;
        emit(GoalsLoaded(
          goals: response.results.reversed.toList(),
          currentPage: 1,
          hasMore: hasMore,
        ));
      },
    );
  }

  Future<void> loadMoreGoals() async {
    if (state.isLoadingMore || !state.hasMore) return;

    final nextPage = state.currentPage + 1;

    emit(GoalsLoaded(
      goals: state.goals,
      currentPage: state.currentPage,
      hasMore: state.hasMore,
      isLoadingMore: true,
    ));

    final result = await _fetchGoalsUseCase(page: nextPage, status: _selectedStatus);

    result.fold(
      (error) => emit(GoalsError(
        message: error,
        goals: state.goals,
        currentPage: state.currentPage,
        hasMore: state.hasMore,
      )),
      (response) {
        final hasMore = response.next != null;
        final allGoals = List<GoalModel>.from(state.goals)
          ..addAll(response.results.reversed);
        emit(GoalsLoaded(
          goals: allGoals,
          currentPage: nextPage,
          hasMore: hasMore,
          isLoadingMore: false,
        ));
      },
    );
  }

  Future<void> createGoal(GoalModel goal) async {
    emit(GoalCreating(
      goals: state.goals,
      currentPage: state.currentPage,
      hasMore: state.hasMore,
    ));

    final result = await _createGoalUseCase(goal);

    result.fold(
      (error) => emit(GoalCreationError(
        message: error,
        goals: state.goals,
        currentPage: state.currentPage,
        hasMore: state.hasMore,
      )),
      (newGoal) {
        final updatedGoals = List<GoalModel>.from(state.goals)
          ..insert(0, newGoal);
        emit(GoalCreated(
          goals: updatedGoals,
          currentPage: state.currentPage,
          hasMore: state.hasMore,
        ));
      },
    );
  }

  Future<void> updateGoal(GoalModel goal) async {
    emit(GoalUpdating(
      goals: state.goals,
      currentPage: state.currentPage,
      hasMore: state.hasMore,
    ));

    final result = await _updateGoalUseCase(goal);

    result.fold(
      (error) => emit(GoalUpdateError(
        message: error,
        goals: state.goals,
        currentPage: state.currentPage,
        hasMore: state.hasMore,
      )),
      (updatedGoal) {
        final updatedGoals = state.goals.map((g) {
          return g.id == updatedGoal.id ? updatedGoal : g;
        }).toList();
        emit(GoalUpdated(
          goals: updatedGoals,
          currentPage: state.currentPage,
          hasMore: state.hasMore,
        ));
      },
    );
  }
}
