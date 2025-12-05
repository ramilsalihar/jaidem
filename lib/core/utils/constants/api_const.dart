abstract class ApiConst {
  static const String baseUrl = 'https://jaidem-back.ru/jaidem/api';

  static const String login = '/user/login/';

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
}
