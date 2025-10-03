import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/domain/usecases/create_goal_usecase.dart';
import 'package:jaidem/features/goals/domain/usecases/fetch_goals_usecase.dart';

part 'goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  final FetchGoalsUseCase _fetchGoalsUseCase;
  final CreateGoalUseCase _createGoalUseCase;

  GoalsCubit({
    required FetchGoalsUseCase fetchGoalsUseCase,
    required CreateGoalUseCase createGoalUseCase,
  })  : _fetchGoalsUseCase = fetchGoalsUseCase,
        _createGoalUseCase = createGoalUseCase,
        super(const GoalsInitial());

  Future<void> fetchGoals() async {
    emit(GoalsLoading(goals: state.goals));

    final result = await _fetchGoalsUseCase();

    result.fold(
      (error) => emit(GoalsError(message: error, goals: state.goals)),
      (goals) => emit(GoalsLoaded(goals: goals)),
    );
  }

  Future<void> createGoal(GoalModel goal) async {
    emit(GoalCreating(goals: state.goals));

    final result = await _createGoalUseCase(goal);

    result.fold(
      (error) => emit(GoalCreationError(message: error, goals: state.goals)),
      (newGoal) {
        final updatedGoals = List<GoalModel>.from(state.goals)..add(newGoal);
        emit(GoalCreated(goals: updatedGoals));
      },
    );
  }
}
