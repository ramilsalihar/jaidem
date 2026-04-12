abstract class ApiConst {
  static const String baseUrl = 'https://jaidem-back.ru/jaidem/api';

  static const String login = '/user/login/';
  static const String tokenRefresh = '/token/refresh/';

  // Profile
  static const String profile = '/user/jaidemchiler/';

  // Forum
  static const String forum = '/core/forum_post/';

  static const String comments = '/core/forum_comment/';

  static  String likeForum(String forumId) => '/core/forum_post/$forumId/like/';

  // Notifications
  static const String notifications = 'notifications';

  // Events
  static const String event = '/core/event/';

  static const String attendance = '/core/attendance/';

  // Goals
  static const String goals = '/core/goal/';

  static const String indicators = '/core/indicators/';

  static const String tasks = '/core/tasks/';

  // Files
  static const String files = '/category/file/';
  static const String divisions = '/category/division/';

  // Trainings
  static const String trainings = '/core/training/';
  static const String trainingAnswers = '/core/training_answer/';
  static const String npsQuestions = '/core/NPS_question/';

  // Opros (Survey)
  static const String oprosStatus = '/core/opros_status/';
  static const String oprosQuestions = '/core/jaidemchi_opros_question/';
  static const String oprosAnswer = '/core/opros_answer/';

  // Birthday
  static const String todayBirthdays = '/core/today_birthdays/';
  static const String birthdayReaction = '/core/birthday_reaction/';

  // Filters
  static const String states = '/category/state/';
  static const String regions = '/category/region/';
  static const String villages = '/category/village/';
  static const String universities = '/core/university/';
  static const String specialities = '/category/speciality/';
  static const String faculties = '/category/faculty/';

  // Profile extras
  static const String otherSchools = '/user/other_school/';
  static const String workPlaces = '/user/work_place/';
  static const String successHistory = '/user/success_history/';
  static const String additionalEducation = '/user/additional_education/';

  // Projects
  static const String projects = '/core/project/';
  static const String projectInterested = '/core/project_interested/';
}
