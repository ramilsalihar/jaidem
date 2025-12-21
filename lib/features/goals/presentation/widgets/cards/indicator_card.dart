import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/helpers/show.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/data/models/goal_task_model.dart';
import 'package:jaidem/features/goals/presentation/cubit/tasks/tasks_cubit.dart';
import 'package:jaidem/features/goals/presentation/cubit/indicators/indicators_cubit.dart';
import 'package:jaidem/features/goals/presentation/helpers/progress_color_helper.dart';
import 'package:jaidem/features/goals/presentation/widgets/buttons/task_add_button.dart';
import 'package:jaidem/features/goals/presentation/widgets/cards/task_card.dart';
import 'package:jaidem/features/goals/presentation/widgets/fields/tasks/deadline_field.dart';
import 'package:jaidem/features/goals/presentation/widgets/fields/tasks/linear_progress_field.dart';
import 'package:jaidem/features/goals/presentation/widgets/fields/tasks/menu_field.dart';

class IndicatorCard extends StatefulWidget {
  final GoalIndicatorModel indicator;

  const IndicatorCard({
    super.key,
    required this.indicator,
  });

  @override
  State<IndicatorCard> createState() => _IndicatorCardState();
}

class _IndicatorCardState extends State<IndicatorCard> with Show {
  bool _isExpanded = false;
  bool _isLoadingTasks = false;
  double? _localProgress;
  final Map<int, bool> _localTaskStates = {};
  GoalIndicatorModel? _updatedIndicator;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded && widget.indicator.id != null) {
      _loadTasks();
    }
  }

  void _loadTasks() {
    setState(() {
      _isLoadingTasks = true;
    });

    context
        .read<TasksCubit>()
        .fetchGoalTasks(widget.indicator.id.toString())
        .then((_) {
      if (mounted) {
        setState(() {
          _isLoadingTasks = false;
          _localProgress = null;
          _localTaskStates.clear();
        });
        _updateLocalProgress();
      }
    });
  }

  void _onTaskToggle(GoalTaskModel task, bool isCompleted) {
    if (task.id == null) return;

    setState(() {
      _localTaskStates[task.id!] = isCompleted;
    });

    _updateLocalProgress();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _refreshIndicatorData();
      }
    });
  }

  void _updateLocalProgress() {
    final state = context.read<TasksCubit>().state;
    final indicatorId = widget.indicator.id?.toString();
    if (indicatorId == null) return;

    final tasks = state.goalTasks[indicatorId] ?? [];
    if (tasks.isEmpty) return;

    int completedTasks = 0;
    for (final task in tasks) {
      if (task.id != null && _localTaskStates.containsKey(task.id!)) {
        if (_localTaskStates[task.id!] == true) completedTasks++;
      } else {
        if (task.isCompleted) completedTasks++;
      }
    }

    final newProgress = (completedTasks / tasks.length) * 100;

    setState(() {
      _localProgress = newProgress;
    });
  }

  void _refreshIndicatorData() {
    if (widget.indicator.id == null) return;

    context
        .read<IndicatorsCubit>()
        .fetchGoalIndicatorById(widget.indicator.id.toString());
  }

  void _smoothTransitionToServerData(double serverProgress) {
    if (_localProgress == null) return;

    if ((_localProgress! - serverProgress).abs() < 2.0) {
      setState(() {
        _localProgress = null;
        _localTaskStates.clear();
      });
      return;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _localProgress = null;
          _localTaskStates.clear();
        });
      }
    });
  }

  void _editIndicator() {
    if (widget.indicator.id == null) return;

    context.router.push(
      AddIndicatorRoute(existingIndicator: widget.indicator),
    );
  }

  void _deleteIndicator() {
    if (widget.indicator.id == null) return;

    // Show confirmation dialog
    showConfirmationDialog(
      context: context,
      title: 'Удалить индикатор',
      content: 'Вы уверены, что хотите удалить этот индикатор?',
      confirmText: 'Удалить',
      confirmTextColor: Colors.red,
      onConfirm: () {
        context
            .read<IndicatorsCubit>()
            .deleteGoalIndicator(widget.indicator.id.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TasksCubit, TasksState>(
          listener: (context, state) {
            if (state is TaskCreated || state is TaskUpdated) {
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _updateLocalProgress();
                }
              });
            }
          },
        ),
        BlocListener<IndicatorsCubit, IndicatorsState>(
          listener: (context, state) {
            if (state is IndicatorFetched &&
                state.indicator.id == widget.indicator.id) {
              // Store server-updated indicator data
              setState(() {
                _updatedIndicator = state.indicator;
              });

              // Use smooth transition to avoid visual jumps
              _smoothTransitionToServerData(state.indicator.progress);
            }
          },
        ),
      ],
      child: _buildIndicatorContent(context),
    );
  }

  Widget _buildIndicatorContent(BuildContext context) {
    // Use updated indicator data from server if available, otherwise use widget.indicator
    final currentIndicator = _updatedIndicator ?? widget.indicator;
    final progressPercent =
        (_localProgress ?? currentIndicator.progress).toInt();
    final progressColor =
        ProgressColorHelper.getColorForProgress(progressPercent);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.shade50,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, currentIndicator),
              if (currentIndicator.endTime != null)
                DeadlineField(endTime: currentIndicator.endTime!),
              LinearProgressField(
                progress: progressPercent / 100,
                progressColor: progressColor,
                isExpanded: _isExpanded,
                onToggleExpansion: _toggleExpansion,
              ),
            ],
          ),
        ),
        if (_isExpanded) _buildTasksSection(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, GoalIndicatorModel indicator) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            indicator.title,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        MenuField(
          onEdit: _editIndicator,
          onDelete: _deleteIndicator,
        ),
      ],
    );
  }

  Widget _buildTasksSection(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        final indicatorId = widget.indicator.id?.toString();
        if (indicatorId == null) return const SizedBox();

        final tasks = state.goalTasks[indicatorId] ?? [];

        if (_isLoadingTasks) {
          return const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ...tasks.map(
                (task) => TaskCard(
                  task: task,
                  key: ValueKey(task.id),
                  onTaskToggle: _onTaskToggle,
                ),
              ),
              const SizedBox(height: 8),
              TaskAddButton(
                text: 'Добавить Задачу',
                onTap: () {
                  _navigateToAddTaskPage(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _navigateToAddTaskPage(BuildContext context) async {
    if (widget.indicator.id == null) return;
    final result = await context.router.push<GoalTaskModel>(
      AddTaskRoute(indicatorId: widget.indicator.id!),
    );

    if (result != null) {
      final task = GoalTaskModel(
        title: result.title,
        isCompleted: false,
        indicator: widget.indicator.id!,
      );

      context.read<TasksCubit>().createGoalTask(task);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _updateLocalProgress();
        }
      });

      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          _refreshIndicatorData();
        }
      });
    }
  }
}
