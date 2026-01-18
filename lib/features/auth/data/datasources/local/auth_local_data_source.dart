abstract class AuthLocalDataSource {
  Future<void> saveToken(
    String? accessToken,
    String? refreshToken,
  );

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  Future<void> saveUserId(String userId);

  Future<void> saveUsername(String username);

  Future<void> saveUserFullname(String fullname);

  Future<void> saveUserAvatar(String? avatar);

  Future<String?> getUserId();

  Future<String?> getUserFullname();

  Future<String?> getUserAvatar();

  Future<bool> logout();
}
