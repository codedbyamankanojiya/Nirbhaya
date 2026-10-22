import 'package:nirbhaya/core/platform/platform_info.dart';

enum Environment { development, staging, production }

class AppConfig {
  static Environment environment = Environment.development;
  
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
