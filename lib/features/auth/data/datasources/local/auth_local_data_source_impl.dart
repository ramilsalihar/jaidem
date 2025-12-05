import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/features/auth/data/datasources/local/auth_local_data_source.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;

  AuthLocalDataSourceImpl(this.prefs);

  @override
  Future<String?> getAccessToken() async {
    return prefs.getString(AppConstants.accessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return prefs.getString(AppConstants.refreshToken);
  }

  @override
  Future<bool> logout() async {
    try {
      await prefs.remove(AppConstants.accessToken);
      await prefs.remove(AppConstants.refreshToken);
      await prefs.remove(AppConstants.userData);
      await prefs.remove(AppConstants.userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> saveToken(String? accessToken, String? refreshToken) async {
    if (accessToken != null) {
      await prefs.setString(AppConstants.accessToken, accessToken);

      try {
        if (!JwtDecoder.isExpired(accessToken)) {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

          // Extract user ID safely
          var rawUserId = decodedToken['sub'] ??
              decodedToken['user_id'] ??
              decodedToken['id'] ??
              decodedToken['userId'];

          if (rawUserId != null) {
            await saveUserId(rawUserId.toString());
          }
        }
      } catch (e) {
        print('Error decoding JWT token: $e');
      }
    }

    if (refreshToken != null) {
      await prefs.setString(AppConstants.refreshToken, refreshToken);
    }
  }

  @override
  Future<void> saveUserId(String userId) async {
    await prefs.setString(AppConstants.userId, userId);
  }

  @override
  Future<String?> getUserId() async {
    return prefs.getString(AppConstants.userId);
  }

  @override
  Future<void> saveUsername(String username) {
    return prefs.setString(AppConstants.userLogin, username);
  }
}
