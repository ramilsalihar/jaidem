import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';
import 'package:jaidem/features/goals/data/models/goal_task_model.dart';

class GoalStatisticsSummary {
  final int completed;
  final int inProgress;
  final int notStarted;

  int get total => completed + inProgress + notStarted;

  const GoalStatisticsSummary({
    required this.completed,
    required this.inProgress,
    required this.notStarted,
  });
}

class GoalStatisticsChartData {
  final List<String> labels;
  final List<Map<String, int>> data;

  const GoalStatisticsChartData({
    required this.labels,
    required this.data,
  });
}

class GoalStatisticsCalculator {
  GoalStatisticsCalculator._();

  /// Computes summary counts from all tasks grouped by their parent indicator's progress.
  static GoalStatisticsSummary computeSummary({
    required List<GoalTaskModel> allTasks,
    required Map<String, GoalIndicatorModel> indicatorMap,
  }) {
    int completed = 0;
    int inProgress = 0;
    int notStarted = 0;

    for (final task in allTasks) {
      if (task.isCompleted) {
        completed++;
      } else {
        final indicatorId = task.indicatorIdString;
        final indicator = indicatorMap[indicatorId];
        if (indicator != null && indicator.progress > 0) {
          inProgress++;
        } else {
          notStarted++;
        }
      }
    }

    return GoalStatisticsSummary(
      completed: completed,
      inProgress: inProgress,
      notStarted: notStarted,
    );
  }

  /// Computes chart data grouped into time buckets for the given mode.
  static GoalStatisticsChartData computeChartData({
    required String mode,
    required List<GoalTaskModel> allTasks,
    required Map<String, GoalIndicatorModel> indicatorMap,
  }) {
    final labels = getLabelsForMode(mode);
    final bucketCount = labels.length;
    final buckets = List.generate(
      bucketCount,
      (_) => <String, int>{'completed': 0, 'inProgress': 0, 'notStarted': 0},
    );

    final now = DateTime.now();

    for (final task in allTasks) {
      final taskDate = task.dateUpdated ?? task.dateCreated;
      if (taskDate == null) continue;

      final bucketIndex = _getBucketIndex(mode, taskDate, now);
      if (bucketIndex < 0 || bucketIndex >= bucketCount) continue;

      if (task.isCompleted) {
        buckets[bucketIndex]['completed'] =
            (buckets[bucketIndex]['completed'] ?? 0) + 1;
      } else {
        final indicatorId = task.indicatorIdString;
        final indicator = indicatorMap[indicatorId];
        if (indicator != null && indicator.progress > 0) {
          buckets[bucketIndex]['inProgress'] =
              (buckets[bucketIndex]['inProgress'] ?? 0) + 1;
        } else {
          buckets[bucketIndex]['notStarted'] =
              (buckets[bucketIndex]['notStarted'] ?? 0) + 1;
        }
      }
    }

    return GoalStatisticsChartData(labels: labels, data: buckets);
  }

  /// Gets labels for the given mode.
  static List<String> getLabelsForMode(String mode) {
    switch (mode) {
      case 'week':
        return ['Дш', 'Ше', 'Ша', 'Бш', 'Жм', 'Иш', 'Жк'];
      case 'month':
        return ['1-жума', '2-жума', '3-жума', '4-жума'];
      case 'year':
        return [
          'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн',
          'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек',
        ];
      default:
        return [];
    }
  }

  /// Returns the bucket index for a given date and mode.
  static int _getBucketIndex(String mode, DateTime date, DateTime now) {
    switch (mode) {
      case 'week':
        return _getWeekBucketIndex(date, now);
      case 'month':
        return _getMonthBucketIndex(date, now);
      case 'year':
        return _getYearBucketIndex(date, now);
      default:
        return -1;
    }
  }

  /// Week mode: 7 days (Mon=0 ... Sun=6) of the current week.
  static int _getWeekBucketIndex(DateTime date, DateTime now) {
    // Get Monday of the current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStart = DateTime(monday.year, monday.month, monday.day);
    final sundayEnd = mondayStart.add(const Duration(days: 7));

    if (date.isBefore(mondayStart) || !date.isBefore(sundayEnd)) return -1;

    return date.weekday - 1; // Monday=0, Sunday=6
  }

  /// Month mode: 4 weeks of the current month.
  static int _getMonthBucketIndex(DateTime date, DateTime now) {
    if (date.year != now.year || date.month != now.month) return -1;

    // Week 1: days 1-7, Week 2: days 8-14, Week 3: days 15-21, Week 4: days 22+
    final day = date.day;
    if (day <= 7) return 0;
    if (day <= 14) return 1;
    if (day <= 21) return 2;
    return 3;
  }

  /// Year mode: 12 months (Jan=0 ... Dec=11) of the current year.
  static int _getYearBucketIndex(DateTime date, DateTime now) {
    if (date.year != now.year) return -1;
    return date.month - 1; // January=0, December=11
  }
}
