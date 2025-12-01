import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/presentation/cubit/indicators/indicators_cubit.dart';

import 'package:jaidem/features/goals/presentation/widgets/cards/goal_card.dart';
import 'package:jaidem/features/goals/presentation/widgets/fields/overview_tab_selector.dart';
import 'package:jaidem/features/goals/presentation/widgets/layout/indicators_list_view.dart';
import 'package:jaidem/features/goals/presentation/widgets/layout/statistics_view.dart';

class GoalOverviewPage extends StatefulWidget {
  final GoalModel goal;

  const GoalOverviewPage({
    super.key,
    required this.goal,
  });

  @override
  State<GoalOverviewPage> createState() => _GoalOverviewPageState();
}

class _GoalOverviewPageState extends State<GoalOverviewPage> {
  int _selectedTab = 0;
  String _statisticsMode = 'month';

  @override
  void initState() {
    super.initState();
    final goalId = widget.goal.id?.toString();
    if (goalId != null) {
      context.read<IndicatorsCubit>().fetchGoalIndicators(goalId);
    }
  }

  void _handleTabChange(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  void _handleStatisticsModeChange(String mode) {
    setState(() {
      _statisticsMode = mode;
    });
  }

  Future<void> _navigateToAddTask() async {
    final result = await context.router.push<GoalIndicatorModel>(
      AddIndicatorRoute(goalId: widget.goal.id),
    );

    if (result != null) {
      context.read<IndicatorsCubit>().createGoalIndicator(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Максат/Изилдөө',
          style: context.textTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: kToolbarHeight),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GoalCard(
                goal: widget.goal,
                readOnly: true,
                isExpanded: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OverviewTabSelector(
                selectedTab: _selectedTab,
                statisticsMode: _statisticsMode,
                onTabChanged: _handleTabChange,
                onStatisticsModeChanged: _handleStatisticsModeChange,
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<IndicatorsCubit, IndicatorsState>(
              builder: (context, state) {
                final goalId = widget.goal.id.toString();
                final indicators = state.goalIndicators[goalId] ?? [];

                if (state is IndicatorsLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Show content based on selected tab
                if (_selectedTab == 0) {
                  return IndicatorsListView(
                    indicators: indicators,
                    onAddIndicator:
                        indicators.length < 3 ? _navigateToAddTask : null,
                  );
                } else {
                  return StatisticsView(mode: _statisticsMode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
