abstract class AuthLocalDataSource {
  Future<void> saveToken(
    String? accessToken,
    String? refreshToken,
  );

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  Future<void> saveUserId(String userId);

  Future<void> saveUsername(String username);

  Future<String?> getUserId();

  Future<bool> logout();
}
