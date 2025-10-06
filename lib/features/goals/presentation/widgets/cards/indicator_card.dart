import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/presentation/helpers/progress_color_helper.dart';

class IndicatorCard extends StatelessWidget {
  final GoalIndicatorModel indicator;

  const IndicatorCard({
    super.key,
    required this.indicator,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = (indicator.progress * 100).toInt();
    final progressColor =
        ProgressColorHelper.getColorForProgress(progressPercent);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (indicator.endTime != null) _buildDeadline(context),
          _buildProgressSection(
            progressPercent,
            progressColor,
            context,
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: AppColors.primary.shade50,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
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
        _IndicatorMenu(),
      ],
    );
  }

  Widget _buildDeadline(BuildContext context) {
    final formattedTime = indicator.endTime != null 
        ? indicator.endTime!.substring(0, 5) // Takes only HH:MM part
        : '';
    
    return Text(
      'Срок до $formattedTime',
      style: context.textTheme.labelLarge?.copyWith(
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildProgressSection(
    int progressPercent,
    Color progressColor,
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: indicator.progress,
              backgroundColor: progressColor.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Text(
          '$progressPercent%',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        // const SizedBox(width: 8),
        // const Icon(
        //   Icons.keyboard_arrow_down,
        //   color: Colors.deepPurple,
        // ),
      ],
    );
  }
}

class _IndicatorMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        // TODO: Implement menu actions
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Изменить')),
        const PopupMenuItem(value: 'delete', child: Text('Удалить')),
      ],
    );
  }
}
