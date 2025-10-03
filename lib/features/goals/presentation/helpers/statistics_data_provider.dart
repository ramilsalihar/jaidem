class StatisticsDataProvider {
  StatisticsDataProvider._();

  static List<String> getLabelsForMode(String mode) {
    return mode == 'month'
        ? [
            'Янв',
            'Фев',
            'Мар',
            'Апр',
            'Май',
            'Июн',
            'Июл',
            'Авг',
            'Сен',
            'Окт',
            'Ноя',
            'Дек'
          ]
        : ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  }

  static List<Map<String, int>> getMockDataForMode(String mode) {
    final length = mode == 'month' ? 12 : 7;
    return List.generate(
      length,
      (index) => {
        'completed': (index % 3 == 0 ? 4 : (index % 3 == 1 ? 3 : 1)),
        'inProgress': (index % 3 == 0 ? 2 : (index % 3 == 1 ? 4 : 3)),
        'notStarted': (index % 3 == 0 ? 1 : (index % 3 == 1 ? 1 : 2)),
      },
    );
  }
}
