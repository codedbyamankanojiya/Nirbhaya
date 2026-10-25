import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirbhaya/app/config.dart';
import 'package:nirbhaya/features/ai_assistant/data/gemini_service.dart';

class SafetySettingsState {
  final bool biometricLock;
  final bool stealthMode;
  final String? pinCode;
  final int sosCountdownSeconds;
  final bool volumeButtonTrigger;
  final double shakeSensitivity; // 0.0 = off, 1.0 = low, 2.0 = med, 3.0 = high
  final bool hapticFeedback;
  final String locationAccuracy; // 'high', 'balanced', 'battery_saver'
  final bool highContrast;
  final double fontScale;
  final String serverUrl;
  final String? geminiApiKey;

  const SafetySettingsState({
    this.biometricLock = false,
    this.stealthMode = false,
    this.pinCode,
    this.sosCountdownSeconds = 3,
    this.volumeButtonTrigger = true,
    this.shakeSensitivity = 2.0,
    this.hapticFeedback = true,
    this.locationAccuracy = 'high',
    this.highContrast = false,
    this.fontScale = 1.0,
    required this.serverUrl,
    this.geminiApiKey,
  });

  SafetySettingsState copyWith({
    bool? biometricLock,
    bool? stealthMode,
    String? pinCode,
    int? sosCountdownSeconds,
    bool? volumeButtonTrigger,
    double? shakeSensitivity,
    bool? hapticFeedback,
    String? locationAccuracy,
    bool? highContrast,
    double? fontScale,
    String? serverUrl,
    String? geminiApiKey,
  }) {
    return SafetySettingsState(
      biometricLock: biometricLock ?? this.biometricLock,
      stealthMode: stealthMode ?? this.stealthMode,
      pinCode: pinCode ?? this.pinCode,
      sosCountdownSeconds: sosCountdownSeconds ?? this.sosCountdownSeconds,
      volumeButtonTrigger: volumeButtonTrigger ?? this.volumeButtonTrigger,
      shakeSensitivity: shakeSensitivity ?? this.shakeSensitivity,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      highContrast: highContrast ?? this.highContrast,
      fontScale: fontScale ?? this.fontScale,
      serverUrl: serverUrl ?? this.serverUrl,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
    );
  }
}

class SafetySettingsNotifier extends StateNotifier<SafetySettingsState> {
  SafetySettingsNotifier()
      : super(SafetySettingsState(serverUrl: AppConfig.effectiveBaseUrl)) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      biometricLock: prefs.getBool('biometric_lock') ?? false,
      stealthMode: prefs.getBool('stealth_mode') ?? false,
      pinCode: prefs.getString('pin_code'),
      sosCountdownSeconds: prefs.getInt('sos_countdown_seconds') ?? 3,
      volumeButtonTrigger: prefs.getBool('volume_button_trigger') ?? true,
      shakeSensitivity: prefs.getDouble('shake_sensitivity') ?? 2.0,
      hapticFeedback: prefs.getBool('haptic_enabled') ?? true,
      locationAccuracy: prefs.getString('location_accuracy') ?? 'high',
      highContrast: prefs.getBool('high_contrast') ?? false,
      fontScale: prefs.getDouble('font_scale') ?? 1.0,
      serverUrl: prefs.getString('custom_server_url') ?? AppConfig.effectiveBaseUrl,
      geminiApiKey: prefs.getString(GeminiService.apiKeyStorageKey) ?? AppConfig.defaultGeminiApiKey,
    );
  }

  Future<void> setBiometricLock(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_lock', enabled);
    state = state.copyWith(biometricLock: enabled);
  }

  Future<void> setStealthMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stealth_mode', enabled);
    state = state.copyWith(stealthMode: enabled);
  }

  Future<void> setPinCode(String? pin) async {
    final prefs = await SharedPreferences.getInstance();
    if (pin != null && pin.isNotEmpty) {
      await prefs.setString('pin_code', pin);
    } else {
      await prefs.remove('pin_code');
    }
    state = state.copyWith(pinCode: pin);
  }

  Future<void> setSosCountdown(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sos_countdown_seconds', seconds);
    state = state.copyWith(sosCountdownSeconds: seconds);
  }

  Future<void> setVolumeButtonTrigger(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('volume_button_trigger', enabled);
    state = state.copyWith(volumeButtonTrigger: enabled);
  }

  Future<void> setShakeSensitivity(double sensitivity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('shake_sensitivity', sensitivity);
    state = state.copyWith(shakeSensitivity: sensitivity);
  }

  Future<void> setHapticFeedback(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_enabled', enabled);
    state = state.copyWith(hapticFeedback: enabled);
  }

  Future<void> setLocationAccuracy(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('location_accuracy', mode);
    state = state.copyWith(locationAccuracy: mode);
  }

  Future<void> setHighContrast(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', enabled);
    state = state.copyWith(highContrast: enabled);
  }

  Future<void> setFontScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_scale', scale);
    state = state.copyWith(fontScale: scale);
  }

  Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_server_url', url);
    state = state.copyWith(serverUrl: url);
  }

  Future<void> setGeminiApiKey(String? key) async {
    final prefs = await SharedPreferences.getInstance();
    if (key != null && key.isNotEmpty) {
      await prefs.setString(GeminiService.apiKeyStorageKey, key);
    } else {
      await prefs.remove(GeminiService.apiKeyStorageKey);
    }
    state = state.copyWith(geminiApiKey: key);
  }
}

final safetySettingsProvider =
    StateNotifierProvider<SafetySettingsNotifier, SafetySettingsState>((ref) {
  return SafetySettingsNotifier();
});

