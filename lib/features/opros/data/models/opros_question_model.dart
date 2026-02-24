class OprosQuestionModel {
  final int id;
  final String textRu;
  final String textKg;
  final String textEn;
  final int priority;
  final String questionType;
  final bool isRate;

  const OprosQuestionModel({
    required this.id,
    required this.textRu,
    required this.textKg,
    required this.textEn,
    required this.priority,
    required this.questionType,
    required this.isRate,
  });

  factory OprosQuestionModel.fromJson(Map<String, dynamic> json) {
    return OprosQuestionModel(
      id: json['id'] ?? 0,
      textRu: json['text_ru'] ?? '',
      textKg: json['text_kg'] ?? '',
      textEn: json['text_en'] ?? '',
      priority: json['priority'] ?? 0,
      questionType: json['question_type'] ?? 'before',
      isRate: json['isRate'] ?? true,
    );
  }

  String getLocalizedText(String languageCode) {
    switch (languageCode) {
      case 'ky':
        return textKg.isNotEmpty ? textKg : textRu;
      case 'en':
        return textEn.isNotEmpty ? textEn : textRu;
      case 'ru':
      default:
        return textRu;
    }
  }
}
