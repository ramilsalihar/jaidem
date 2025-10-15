part of 'indicators_cubit.dart';

abstract class IndicatorsState extends Equatable {
  final Map<String, List<GoalIndicatorModel>> goalIndicators;
  
  const IndicatorsState({
    this.goalIndicators = const {},
  });

  @override
  List<Object> get props => [goalIndicators];
}

class IndicatorsInitial extends IndicatorsState {
  const IndicatorsInitial() : super();
}

class IndicatorsLoading extends IndicatorsState {
  const IndicatorsLoading({
    Map<String, List<GoalIndicatorModel>> goalIndicators = const {},
  }) : super(goalIndicators: goalIndicators);
}

class IndicatorsLoaded extends IndicatorsState {
  const IndicatorsLoaded({
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);
}

class IndicatorsError extends IndicatorsState {
  final String message;

  const IndicatorsError({
    required this.message,
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);

  @override
  List<Object> get props => [message, goalIndicators];
}

class IndicatorCreating extends IndicatorsState {
  const IndicatorCreating({
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);
}

class IndicatorCreated extends IndicatorsState {
  const IndicatorCreated({
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);
}

class IndicatorCreationError extends IndicatorsState {
  final String message;

  const IndicatorCreationError({
    required this.message,
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);

  @override
  List<Object> get props => [message, goalIndicators];
}

class IndicatorUpdating extends IndicatorsState {
  const IndicatorUpdating({
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);
}

class IndicatorUpdated extends IndicatorsState {
  const IndicatorUpdated({
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);
}

class IndicatorUpdateError extends IndicatorsState {
  final String message;

  const IndicatorUpdateError({
    required this.message,
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);

  @override
  List<Object> get props => [message, goalIndicators];
}

class IndicatorDeleting extends IndicatorsState {
  const IndicatorDeleting({
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);
}

class IndicatorDeleted extends IndicatorsState {
  const IndicatorDeleted({
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);
}

class IndicatorDeleteError extends IndicatorsState {
  final String message;

  const IndicatorDeleteError({
    required this.message,
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);

  @override
  List<Object> get props => [message, goalIndicators];
}

class IndicatorFetching extends IndicatorsState {
  const IndicatorFetching({
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);
}

class IndicatorFetched extends IndicatorsState {
  final GoalIndicatorModel indicator;

  const IndicatorFetched({
    required this.indicator,
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);

  @override
  List<Object> get props => [indicator, goalIndicators];
}

class IndicatorFetchError extends IndicatorsState {
  final String message;

  const IndicatorFetchError({
    required this.message,
    required Map<String, List<GoalIndicatorModel>> goalIndicators,
  }) : super(goalIndicators: goalIndicators);

  @override
  List<Object> get props => [message, goalIndicators];
}
