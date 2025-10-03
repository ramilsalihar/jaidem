import 'package:flutter/material.dart';
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
          _buildHeader(),
          if (indicator.endTime != null) _buildDeadline(),
          const SizedBox(height: 12),
          _buildProgressSection(progressPercent, progressColor),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            indicator.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        _IndicatorMenu(),
      ],
    );
  }

  Widget _buildDeadline() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'Срок до ${indicator.endTime}',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProgressSection(int progressPercent, Color progressColor) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: indicator.progress,
              backgroundColor: progressColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$progressPercent%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.deepPurple,
        ),
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
