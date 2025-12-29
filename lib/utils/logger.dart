/// Production-safe logging utility
/// Set [enableLogging] to false in production to disable all logs
class AppLogger {
  static const bool enableLogging = true; // Set to false in production

  static void debug(String message) {
    if (enableLogging) {
      print('🔵 $message');
    }
  }

  static void info(String message) {
    if (enableLogging) {
      print('ℹ️ $message');
    }
  }

  static void warning(String message) {
    if (enableLogging) {
      print('⚠️ $message');
    }
  }

  static void error(String message) {
    if (enableLogging) {
      print('❌ $message');
    }
  }

  static void success(String message) {
    if (enableLogging) {
      print('✅ $message');
    }
  }
}
