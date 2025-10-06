import 'package:flutter/material.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/presentation/widgets/cards/indicator_card.dart';
import 'package:jaidem/features/goals/presentation/widgets/buttons/task_add_button.dart';

class IndicatorsListView extends StatelessWidget {
  final List<GoalIndicatorModel> indicators;
  final VoidCallback? onAddIndicator;

  const IndicatorsListView({
    super.key,
    required this.indicators,
    this.onAddIndicator,
  });

  @override
  Widget build(BuildContext context) {
    final shouldShowAddButton = indicators.length < 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ...indicators.map((indicator) => IndicatorCard(indicator: indicator)),
          if (shouldShowAddButton)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TaskAddButton(
                onTap: onAddIndicator ?? () {},
              ),
            ),
        ],
      ),
    );
  }
}
