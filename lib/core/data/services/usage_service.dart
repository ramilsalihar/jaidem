import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsageService {
  static final UsageService _instance = UsageService._internal();
  factory UsageService() => _instance;
  UsageService._internal();

  FirebaseFirestore get _firestore => sl<FirebaseFirestore>();
  SharedPreferences get _prefs => sl<SharedPreferences>();

  String? get _userId => _prefs.getString(AppConstants.userId);

  /// Updates the app last used time in Firestore
  Future<void> updateAppLastUsedTime() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _firestore.collection('usages').doc(userId).set({
        'appLastUsedTime': FieldValue.serverTimestamp(),
        'userId': userId,
      }, SetOptions(merge: true));
    } catch (_) {
      // Silently handle error to not disrupt user experience
    }
  }

  /// Updates the chat last used time in Firestore
  Future<void> updateChatLastUsedTime() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      await _firestore.collection('usages').doc(userId).set({
        'chatLastUsedTime': FieldValue.serverTimestamp(),
        'userId': userId,
      }, SetOptions(merge: true));
    } catch (_) {
      // Silently handle error to not disrupt user experience
    }
  }

  /// Updates both app and chat usage times
  Future<void> updateAllUsageTimes() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    try {
      final now = FieldValue.serverTimestamp();
      await _firestore.collection('usages').doc(userId).set({
        'appLastUsedTime': now,
        'chatLastUsedTime': now,
        'userId': userId,
      }, SetOptions(merge: true));
    } catch (_) {
      // Silently handle error
    }
  }
}
