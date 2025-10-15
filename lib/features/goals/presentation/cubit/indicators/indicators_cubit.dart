import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/domain/usecases/create_goal_indicator_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/delete_goal_indicator_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goal_indicators_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goal_indicator_by_id_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/update_goal_indicator_usecase.dart';

part 'indicators_state.dart';

class IndicatorsCubit extends Cubit<IndicatorsState> {
  final FetchGoalIndicatorsUseCase _fetchGoalIndicatorsUseCase;
  final CreateGoalIndicatorUseCase _createGoalIndicatorUseCase;
  final UpdateGoalIndicatorUseCase _updateGoalIndicatorUseCase;
  final DeleteGoalIndicatorUseCase _deleteGoalIndicatorUseCase;
  final FetchGoalIndicatorByIdUseCase _fetchGoalIndicatorByIdUseCase;

  IndicatorsCubit({
    required FetchGoalIndicatorsUseCase fetchGoalIndicatorsUseCase,
    required CreateGoalIndicatorUseCase createGoalIndicatorUseCase,
    required UpdateGoalIndicatorUseCase updateGoalIndicatorUseCase,
    required DeleteGoalIndicatorUseCase deleteGoalIndicatorUseCase,
    required FetchGoalIndicatorByIdUseCase fetchGoalIndicatorByIdUseCase,
  })  : _fetchGoalIndicatorsUseCase = fetchGoalIndicatorsUseCase,
        _createGoalIndicatorUseCase = createGoalIndicatorUseCase,
        _updateGoalIndicatorUseCase = updateGoalIndicatorUseCase,
        _deleteGoalIndicatorUseCase = deleteGoalIndicatorUseCase,
        _fetchGoalIndicatorByIdUseCase = fetchGoalIndicatorByIdUseCase,
        super(const IndicatorsInitial());

  Future<void> fetchGoalIndicators(String goalId) async {
    emit(IndicatorsLoading(goalIndicators: state.goalIndicators));

    final result = await _fetchGoalIndicatorsUseCase(goalId);

    result.fold(
      (error) {
        emit(IndicatorsError(
          message: error,
          goalIndicators: state.goalIndicators,
        ));
      },
      (indicators) {
        final updatedIndicators =
            Map<String, List<GoalIndicatorModel>>.from(state.goalIndicators);
        // Sort indicators by most recent ID (assuming higher ID means more recent)
        final sortedIndicators = List<GoalIndicatorModel>.from(indicators)
          ..sort((a, b) {
            // Handle null IDs by putting them at the end
            if (a.id == null && b.id == null) return 0;
            if (a.id == null) return 1;
            if (b.id == null) return -1;
            return b.id!.compareTo(a.id!);
          });
        updatedIndicators[goalId] = sortedIndicators;
        emit(IndicatorsLoaded(goalIndicators: updatedIndicators));
      },
    );
  }

  Future<void> createGoalIndicator(GoalIndicatorModel indicator) async {
    emit(IndicatorCreating(goalIndicators: state.goalIndicators));

    final result = await _createGoalIndicatorUseCase(indicator);

    result.fold(
      (error) => emit(IndicatorCreationError(
        message: error,
        goalIndicators: state.goalIndicators,
      )),
      (newIndicator) {
        final updatedIndicators =
            Map<String, List<GoalIndicatorModel>>.from(state.goalIndicators);
        final goalId = newIndicator.goalIdString;

        if (updatedIndicators.containsKey(goalId)) {
          updatedIndicators[goalId] =
              List<GoalIndicatorModel>.from(updatedIndicators[goalId]!)
                ..insert(0, newIndicator);
        } else {
          updatedIndicators[goalId] = [newIndicator];
        }

        emit(IndicatorCreated(goalIndicators: updatedIndicators));
      },
    );
  }

  Future<void> updateGoalIndicator(GoalIndicatorModel indicator) async {
    if (indicator.id == null) {
      emit(IndicatorUpdateError(
        message: 'Cannot update indicator without ID',
        goalIndicators: state.goalIndicators,
      ));
      return;
    }

    emit(IndicatorUpdating(goalIndicators: state.goalIndicators));

    final result = await _updateGoalIndicatorUseCase(indicator);

    result.fold(
      (error) => emit(IndicatorUpdateError(
        message: error,
        goalIndicators: state.goalIndicators,
      )),
      (updatedIndicator) {
        final updatedIndicators =
            Map<String, List<GoalIndicatorModel>>.from(state.goalIndicators);
        final goalId = updatedIndicator.goalIdString;

        if (updatedIndicators.containsKey(goalId)) {
          final indicatorList =
              List<GoalIndicatorModel>.from(updatedIndicators[goalId]!);
          final indicatorIndex =
              indicatorList.indexWhere((i) => i.id == updatedIndicator.id);

          if (indicatorIndex != -1) {
            indicatorList[indicatorIndex] = updatedIndicator;
            updatedIndicators[goalId] = indicatorList;
          }
        }

        emit(IndicatorUpdated(goalIndicators: updatedIndicators));
      },
    );
  }

  Future<void> deleteGoalIndicator(String indicatorId) async {
    emit(IndicatorDeleting(goalIndicators: state.goalIndicators));

    final result = await _deleteGoalIndicatorUseCase(indicatorId);

    result.fold(
      (error) => emit(IndicatorDeleteError(
        message: error,
        goalIndicators: state.goalIndicators,
      )),
      (_) {
        final updatedIndicators =
            Map<String, List<GoalIndicatorModel>>.from(state.goalIndicators);

        for (final goalId in updatedIndicators.keys) {
          updatedIndicators[goalId] = updatedIndicators[goalId]!
              .where((indicator) => indicator.id.toString() != indicatorId)
              .toList();
        }

        emit(IndicatorDeleted(goalIndicators: updatedIndicators));
      },
    );
  }

  Future<void> fetchGoalIndicatorById(String indicatorId) async {
    emit(IndicatorFetching(goalIndicators: state.goalIndicators));

    final result = await _fetchGoalIndicatorByIdUseCase(indicatorId);

    result.fold(
      (error) => emit(IndicatorFetchError(
        message: error,
        goalIndicators: state.goalIndicators,
      )),
      (indicator) => emit(IndicatorFetched(
        indicator: indicator,
        goalIndicators: state.goalIndicators,
      )),
    );
  }
}
