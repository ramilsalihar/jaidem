import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/goals/data/models/goal_task_model.dart';
import 'package:jaidem/features/goals/presentation/cubit/tasks/tasks_cubit.dart';

class TaskCard extends StatefulWidget {
  final GoalTaskModel task;
  final Function(GoalTaskModel task, bool isCompleted)? onTaskToggle;

  const TaskCard({
    super.key,
    required this.task,
    this.onTaskToggle,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task.isCompleted;
  }

  void _toggleCompletion() {
    setState(() {
      _isCompleted = !_isCompleted;
    });

    // Notify parent about the task toggle with current state
    widget.onTaskToggle?.call(widget.task, _isCompleted);

    final updatedTask = widget.task.copyWith(isCompleted: _isCompleted);
    context.read<TasksCubit>().updateGoalTask(updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
          color: AppColors.primary.shade50,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.shade50,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.task.title,
              style: context.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _toggleCompletion,
            child: _isCompleted
                ? Icon(
                    Icons.check_circle,
                    color: AppColors.green,
                    size: 30,
                  )
                : Icon(
                    Icons.check_circle_outline,
                    color: Colors.grey.shade400,
                    size: 30,
                  ),
          ),
        ],
      ),
    );
  }
}
