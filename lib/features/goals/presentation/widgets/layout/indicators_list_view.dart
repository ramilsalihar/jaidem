import 'package:flutter/material.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/presentation/widgets/cards/indicator_card.dart';

class IndicatorsListView extends StatelessWidget {
  final List<GoalIndicatorModel> indicators;

  const IndicatorsListView({
    super.key,
    required this.indicators,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: indicators.length,
      itemBuilder: (context, index) {
        return IndicatorCard(indicator: indicators[index]);
      },
    );
  }
}