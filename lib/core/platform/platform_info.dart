import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformInfo {
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  static bool get isMobile => isAndroid || isIOS;
  static bool get supportsPhoneCalls => isMobile;
  static bool get supportsBackgroundLocation => isMobile;
  static bool get supportsVibration => isMobile;
  static bool get supportsCamera => isMobile || isWeb;
}
