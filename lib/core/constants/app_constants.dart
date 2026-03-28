/// Global application constants
class AppConstants {
  AppConstants._();

  // Firestore collections
  static const String usersCollection = 'users';
  static const String conversationsCollection = 'conversations';
  static const String messagesCollection = 'messages';

  // Hive box keys
  static const String settingsBox = 'settings';
  static const String userCacheBox = 'user_cache';
  static const String themeKey = 'isDarkMode';
  static const String cachedUserKey = 'cached_user';

  // Storage paths
  static const String avatarsStoragePath = 'avatars';
  static const String imagesStoragePath = 'chat_images';
  static const String voiceStoragePath = 'voice_messages';

  // Pagination
  static const int messagesPerPage = 30;

  // Timeouts
  static const Duration typingTimeout = Duration(seconds: 3);
  static const Duration onlineTimeout = Duration(minutes: 5);

  // Animations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 600);
}
