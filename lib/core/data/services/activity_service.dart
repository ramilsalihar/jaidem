import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';

/// Reports that the current user is active in the app.
///
/// Pings the backend (`POST /user/ping/`) on app launch and on resume from
/// background so the Jaidemchiler list can be ordered by who was online most
/// recently. Best-effort: failures are swallowed and never surface to the user.
class ActivityService {
  final Dio dio;

  const ActivityService({required this.dio});

  Future<void> updateLastTimeInApp() async {
    try {
      await dio.post(ApiConst.updateLastTimeInApp);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ActivityService.updateLastTimeInApp failed: $e');
      }
    }
  }
}
