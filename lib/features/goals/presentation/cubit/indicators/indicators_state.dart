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
    super.goalIndicators,
  });
}

class IndicatorsLoaded extends IndicatorsState {
  const IndicatorsLoaded({
    required super.goalIndicators,
  });
}

class IndicatorsError extends IndicatorsState {
  final String message;

  const IndicatorsError({
    required this.message,
    required super.goalIndicators,
  });

  @override
  List<Object> get props => [message, goalIndicators];
}

class IndicatorCreating extends IndicatorsState {
  const IndicatorCreating({
    required super.goalIndicators,
  });
}

class IndicatorCreated extends IndicatorsState {
  const IndicatorCreated({
    required super.goalIndicators,
  });
}

class IndicatorCreationError extends IndicatorsState {
  final String message;

  const IndicatorCreationError({
    required this.message,
    required super.goalIndicators,
  });

  @override
  List<Object> get props => [message, goalIndicators];
}

class IndicatorUpdating extends IndicatorsState {
  const IndicatorUpdating({
    required super.goalIndicators,
  });
}

class IndicatorUpdated extends IndicatorsState {
  const IndicatorUpdated({
    required super.goalIndicators,
  });
}

class IndicatorUpdateError extends IndicatorsState {
  final String message;

  const IndicatorUpdateError({
    required this.message,
    required super.goalIndicators,
  });

  @override
  List<Object> get props => [message, goalIndicators];
}

class IndicatorDeleting extends IndicatorsState {
  const IndicatorDeleting({
    required super.goalIndicators,
  });
}

class IndicatorDeleted extends IndicatorsState {
  const IndicatorDeleted({
    required super.goalIndicators,
  });
}

class IndicatorDeleteError extends IndicatorsState {
  final String message;

  const IndicatorDeleteError({
    required this.message,
    required super.goalIndicators,
  });

  @override
  List<Object> get props => [message, goalIndicators];
}

class IndicatorFetching extends IndicatorsState {
  const IndicatorFetching({
    required super.goalIndicators,
  });
}

class IndicatorFetched extends IndicatorsState {
  final GoalIndicatorModel indicator;

  const IndicatorFetched({
    required this.indicator,
    required super.goalIndicators,
  });

  @override
  List<Object> get props => [indicator, goalIndicators];
}

class IndicatorFetchError extends IndicatorsState {
  final String message;

  const IndicatorFetchError({
    required this.message,
    required super.goalIndicators,
  });

  @override
  List<Object> get props => [message, goalIndicators];
}
