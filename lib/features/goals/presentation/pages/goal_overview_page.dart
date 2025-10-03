import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/presentation/widgets/cards/goal_card.dart';
import 'package:jaidem/features/goals/presentation/widgets/fields/overview_tab_selector.dart';
import 'package:jaidem/features/goals/presentation/widgets/layout/indicators_list_view.dart';
import 'package:jaidem/features/goals/presentation/widgets/layout/statistics_view.dart';

class GoalOverviewPage extends StatefulWidget {
  final GoalModel goal;
  final List<GoalIndicatorModel> indicators;

  const GoalOverviewPage({
    super.key,
    required this.goal,
    required this.indicators,
  });

  @override
  State<GoalOverviewPage> createState() => _GoalOverviewPageState();
}

class _GoalOverviewPageState extends State<GoalOverviewPage> {
  int _selectedTab = 0;
  bool _isGoalExpanded = true;
  String _statisticsMode = 'month';
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleTabChange(int index) {
    setState(() {
      _selectedTab = index;
      if (index == 1) {
        _isGoalExpanded = false;
      }
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleGoalExpansionToggle() {
    if (_selectedTab == 0) {
      setState(() {
        _isGoalExpanded = !_isGoalExpanded;
      });
    }
  }

  void _handleStatisticsModeChange(String mode) {
    setState(() {
      _statisticsMode = mode;
    });
  }

  void _handleAddIndicator() {
    // TODO: Implement add indicator
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
          'Цель/Учеба',
          style: context.textTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: Column(
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
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _handleTabChange,
              children: [
                IndicatorsListView(indicators: widget.indicators),
                StatisticsView(mode: _statisticsMode),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedTab != 0) return null;

    return FloatingActionButton.extended(
      onPressed: _handleAddIndicator,
      backgroundColor: Theme.of(context).primaryColor,
      label: const Text('Добавить новую задачу'),
      icon: const Icon(Icons.add),
    );
  }
}
