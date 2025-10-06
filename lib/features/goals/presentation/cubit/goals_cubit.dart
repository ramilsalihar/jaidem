import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/domain/usecases/create_goal_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/create_goal_indicator_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goals_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goal_indicators_usecase.dart';

part 'goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  final FetchGoalsUseCase _fetchGoalsUseCase;
  final CreateGoalUseCase _createGoalUseCase;
  final FetchGoalIndicatorsUseCase _fetchGoalIndicatorsUseCase;
  final CreateGoalIndicatorUseCase _createGoalIndicatorUseCase;

  GoalsCubit({
    required FetchGoalsUseCase fetchGoalsUseCase,
    required CreateGoalUseCase createGoalUseCase,
    required FetchGoalIndicatorsUseCase fetchGoalIndicatorsUseCase,
    required CreateGoalIndicatorUseCase createGoalIndicatorUseCase,
  })  : _fetchGoalsUseCase = fetchGoalsUseCase,
        _createGoalUseCase = createGoalUseCase,
        _fetchGoalIndicatorsUseCase = fetchGoalIndicatorsUseCase,
        _createGoalIndicatorUseCase = createGoalIndicatorUseCase,
        super(const GoalsInitial());

  Future<void> fetchGoals() async {
    emit(GoalsLoading(goals: state.goals, goalIndicators: state.goalIndicators));

    final result = await _fetchGoalsUseCase();

    result.fold(
      (error) => emit(GoalsError(message: error, goals: state.goals, goalIndicators: state.goalIndicators)),
      (goals) => emit(GoalsLoaded(goals: goals.reversed.toList(), goalIndicators: state.goalIndicators)),
    );
  }

  Future<void> createGoal(GoalModel goal) async {
    emit(GoalCreating(goals: state.goals, goalIndicators: state.goalIndicators));

    final result = await _createGoalUseCase(goal);

    result.fold(
      (error) => emit(GoalCreationError(message: error, goals: state.goals, goalIndicators: state.goalIndicators)),
      (newGoal) {
        final updatedGoals = List<GoalModel>.from(state.goals)..insert(0, newGoal);
        emit(GoalCreated(goals: updatedGoals, goalIndicators: state.goalIndicators));
      },
    );
  }

  Future<void> fetchGoalIndicators(String goalId) async {
    print('GoalsCubit: Fetching indicators for goalId: $goalId');
    emit(GoalIndicatorsLoading(goals: state.goals, goalIndicators: state.goalIndicators));

    final result = await _fetchGoalIndicatorsUseCase(goalId);

    result.fold(
      (error) {
        print('GoalsCubit: Error fetching indicators: $error');
        emit(GoalIndicatorsError(
          message: error,
          goals: state.goals,
          goalIndicators: state.goalIndicators,
        ));
      },
      (indicators) {
        print('GoalsCubit: Fetched ${indicators.length} indicators for goalId: $goalId');
        final updatedIndicators = Map<String, List<GoalIndicatorModel>>.from(state.goalIndicators);
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
        print('GoalsCubit: Updated indicators map: ${updatedIndicators.keys}');
        emit(GoalIndicatorsLoaded(goals: state.goals, goalIndicators: updatedIndicators));
      },
    );
  }

  Future<void> createGoalIndicator(GoalIndicatorModel indicator) async {
    emit(GoalIndicatorCreating(goals: state.goals, goalIndicators: state.goalIndicators));

    final result = await _createGoalIndicatorUseCase(indicator);

    result.fold(
      (error) => emit(GoalIndicatorCreationError(
        message: error,
        goals: state.goals,
        goalIndicators: state.goalIndicators,
      )),
      (newIndicator) {
        final updatedIndicators = Map<String, List<GoalIndicatorModel>>.from(state.goalIndicators);
        final goalId = newIndicator.goal.toString();
        
        if (updatedIndicators.containsKey(goalId)) {
          updatedIndicators[goalId] = List<GoalIndicatorModel>.from(updatedIndicators[goalId]!)..add(newIndicator);
        } else {
          updatedIndicators[goalId] = [newIndicator];
        }
        
        emit(GoalIndicatorCreated(goals: state.goals, goalIndicators: updatedIndicators));
      },
    );
  }

  Future<void> createGoalWithIndicators(GoalModel goal, List<GoalIndicatorModel> indicators) async {
    emit(GoalCreating(goals: state.goals, goalIndicators: state.goalIndicators));

    // Step 1: Create the goal first
    final goalResult = await _createGoalUseCase(goal);

    await goalResult.fold(
      (error) async => emit(GoalCreationError(message: error, goals: state.goals, goalIndicators: state.goalIndicators)),
      (createdGoal) async {
        // Update goals list with the new goal
        final updatedGoals = List<GoalModel>.from(state.goals)..insert(0, createdGoal);
        emit(GoalCreated(goals: updatedGoals, goalIndicators: state.goalIndicators));

        // Step 2: Create indicators if they exist
        if (indicators.isNotEmpty) {
          final goalId = createdGoal.id?.toString();
          if (goalId != null) {
            // Create indicators one by one
            final updatedIndicators = Map<String, List<GoalIndicatorModel>>.from(state.goalIndicators);
            final createdIndicators = <GoalIndicatorModel>[];

            for (final indicator in indicators) {
              // Update indicator with the actual goal ID
              final updatedIndicator = indicator.copyWith(goal: createdGoal.id);
              
              emit(GoalIndicatorCreating(goals: updatedGoals, goalIndicators: updatedIndicators));
              
              final indicatorResult = await _createGoalIndicatorUseCase(updatedIndicator);
              
              final shouldContinue = await indicatorResult.fold(
                (error) async {
                  emit(GoalIndicatorCreationError(
                    message: error,
                    goals: updatedGoals,
                    goalIndicators: updatedIndicators,
                  ));
                  return false; // Stop creating more indicators on error
                },
                (newIndicator) async {
                  createdIndicators.add(newIndicator);
                  updatedIndicators[goalId] = List<GoalIndicatorModel>.from(createdIndicators);
                  emit(GoalIndicatorCreated(goals: updatedGoals, goalIndicators: updatedIndicators));
                  return true; // Continue with next indicator
                },
              );

              if (!shouldContinue) break;
            }
          }
        }
      },
    );
  }
}
