import 'package:nirbhaya/core/platform/platform_info.dart';

enum Environment { development, staging, production }

class AppConfig {
  static Environment environment = Environment.development;
  
  /// Default Google Gemini API Key for Nirbhaya AI Safety & Legal Assistant.
  /// Pass via `--dart-define=GEMINI_API_KEY=your_key` during build or enter in app Settings.
  /// Kept empty by default to prevent credential leakage when pushed to public GitHub repositories.
  static const String defaultGeminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development: return 'http://10.0.2.2:3000'; // Android emulator
      case Environment.staging: return 'https://staging-api.nirbhaya.com';
      case Environment.production: return 'https://api.nirbhaya.com';
    }
  }
  
  static const String apiPrefix = '/api/v1';
  
  static String get effectiveBaseUrl {
    if (environment == Environment.development) {
      if (PlatformInfo.isWeb || PlatformInfo.isDesktop) {
        return 'http://localhost:3000';
      }
      if (PlatformInfo.isIOS) {
        return 'http://localhost:3000';
      }
      // Default to Android emulator loopback
      return 'http://10.0.2.2:3000';
    }
    return apiBaseUrl;
  }
}
