class AppConstants {
  // App Info
  static const String appName = 'Jaidem';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userData = 'user_data';
  static const String isFirstTime = 'is_first_time';
  static const String userLogin = 'user_login';

  // API
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // UI
  static const double borderRadius = 8.0;
  static const double padding = 16.0;
  static const double margin = 16.0;

  // Default items
  static const String defaultForumPost =
      "https://cdn.britannica.com/99/128399-050-EB6E336F/Temple-of-Saturn-Roman-Forum-Rome.jpg";

  static const String defaultEventImage =
      'https://cdn-cjhkj.nitrocdn.com/spotme.com/wp-content/uploads/2020/07/Hero-1.jpg';

  // Firebase Collections
  static const String chatsCollection = 'chats';
  static const String mentorsCollection = 'mentors';
  static const String usersCollection = 'users';
  static const String adminCollection = 'admin';
}
