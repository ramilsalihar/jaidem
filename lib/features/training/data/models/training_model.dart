class NPSQuestion {
  final int id;
  final String question;
  final String textRu;
  final String textKg;
  final String textEn;

  NPSQuestion({
    required this.id,
    required this.question,
    required this.textRu,
    required this.textKg,
    required this.textEn,
  });

  factory NPSQuestion.fromJson(Map<String, dynamic> json) {
    return NPSQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      textRu: json['text_ru'] ?? json['question'] ?? '',
      textKg: json['text_kg'] ?? json['question'] ?? '',
      textEn: json['text_en'] ?? json['question'] ?? '',
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
        return textRu.isNotEmpty ? textRu : question;
    }
  }
}

class TrainingAnswer {
  final int id;
  final int rate;
  final String comment;
  final String author;
  final int training;
  final int question;

  TrainingAnswer({
    required this.id,
    required this.rate,
    required this.comment,
    required this.author,
    required this.training,
    required this.question,
  });

  factory TrainingAnswer.fromJson(Map<String, dynamic> json) {
    // Handle rate as either int or double from API
    final rateValue = json['rate'];
    final rate = rateValue is double ? rateValue.toInt() : (rateValue as int?) ?? 0;

    // Handle author - can be an object with 'id' or just an id
    final authorValue = json['author'];
    final author = authorValue is Map
        ? (authorValue['id']?.toString() ?? '')
        : (authorValue?.toString() ?? '');

    // Handle training - can be an object with 'id' or just an id
    final trainingValue = json['training'];
    final training = trainingValue is Map
        ? (trainingValue['id'] as int?) ?? 0
        : (trainingValue as int?) ?? 0;

    // Handle question - can be an object with 'id' or just an id
    final questionValue = json['question'];
    final question = questionValue is Map
        ? (questionValue['id'] as int?) ?? 0
        : (questionValue as int?) ?? 0;

    return TrainingAnswer(
      id: json['id'] ?? 0,
      rate: rate,
      comment: json['comment'] ?? '',
      author: author,
      training: training,
      question: question,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'comment': comment,
      'author': author,
      'training': training,
      'question': question,
    };
  }
}

class TrainingFlow {
  final int id;
  final String name;
  final String description;
  final int year;
  final int generation;
  final int orderNumber;
  final String dateCreated;
  final String? afterSurveyOpenDate;

  TrainingFlow({
    required this.id,
    required this.name,
    required this.description,
    required this.year,
    required this.generation,
    required this.orderNumber,
    required this.dateCreated,
    this.afterSurveyOpenDate,
  });

  factory TrainingFlow.fromJson(Map<String, dynamic> json) {
    return TrainingFlow(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      year: json['year'] ?? 0,
      generation: json['generation'] ?? 0,
      orderNumber: json['orderNumber'] ?? 0,
      dateCreated: json['dateCreated'] ?? '',
      afterSurveyOpenDate: json['after_survey_open_date'],
    );
  }
}

class TrainingAttendance {
  final int id;
  final int jaidemchiId;
  final String status;
  final String comment;

  TrainingAttendance({
    required this.id,
    required this.jaidemchiId,
    required this.status,
    required this.comment,
  });

  factory TrainingAttendance.fromJson(Map<String, dynamic> json) {
    return TrainingAttendance(
      id: json['id'] ?? 0,
      jaidemchiId: json['jaidemchi_id'] ?? 0,
      status: json['status'] ?? '',
      comment: json['comment'] ?? '',
    );
  }
}

class TrainingModel {
  final int id;
  final String name;
  final String dateCreated;
  final List<TrainingFlow> flows;
  final List<TrainingAttendance> attendances;
  final int presentCount;
  final int absentCount;
  final int respectfulCount;
  final bool isArchive;

  TrainingModel({
    required this.id,
    required this.name,
    required this.dateCreated,
    required this.flows,
    required this.attendances,
    required this.presentCount,
    required this.absentCount,
    required this.respectfulCount,
    required this.isArchive,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      dateCreated: json['date_created'] ?? '',
      flows: (json['flow'] as List<dynamic>?)
              ?.map((e) => TrainingFlow.fromJson(e))
              .toList() ??
          [],
      attendances: (json['attendances'] as List<dynamic>?)
              ?.map((e) => TrainingAttendance.fromJson(e))
              .toList() ??
          [],
      presentCount: json['present_count'] ?? 0,
      absentCount: json['absent_count'] ?? 0,
      respectfulCount: json['respectful_count'] ?? 0,
      isArchive: json['isArchive'] ?? false,
    );
  }

  int get totalAttendees => presentCount + absentCount + respectfulCount;

  double get attendancePercentage {
    if (totalAttendees == 0) return 0;
    return (presentCount / totalAttendees) * 100;
  }
}
