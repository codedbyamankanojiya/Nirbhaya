import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirbhaya/app/theme.dart';
import 'package:nirbhaya/features/auth/providers/auth_providers.dart';
import 'package:nirbhaya/features/settings/providers/settings_provider.dart';
import 'package:nirbhaya/features/settings/providers/theme_provider.dart';
import 'package:nirbhaya/shared/extensions/context_extensions.dart';
import 'package:nirbhaya/shared/widgets/app_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _editPinCode(BuildContext context, WidgetRef ref, String? currentPin) async {
    final controller = TextEditingController(text: currentPin ?? '');
    final newPin = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Safety PIN Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set a 4-digit security PIN to unlock SOS cancellation or access private evidence vault.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 20),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '••••',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          if (currentPin != null)
            TextButton(
              onPressed: () => Navigator.pop(ctx, ''),
              child: const Text('Remove PIN', style: TextStyle(color: Colors.redAccent)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );

    if (newPin != null) {
      await ref.read(safetySettingsProvider.notifier).setPinCode(newPin.isEmpty ? null : newPin);
      if (context.mounted) {
        context.showSnackBar(newPin.isEmpty ? 'PIN code removed.' : 'Safety PIN code updated.');
      }
    }
  }

  Future<void> _editServerUrl(BuildContext context, WidgetRef ref, String currentUrl) async {
    final controller = TextEditingController(text: currentUrl);
    final newUrl = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Backend REST API Server', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify custom API server host. For Android emulator use http://10.0.2.2:3000, or your LAN IP (e.g. http://192.168.1.5:3000) for physical device testing.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Host URL',
                hintText: 'http://10.0.2.2:3000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newUrl != null && newUrl.isNotEmpty) {
      await ref.read(safetySettingsProvider.notifier).setServerUrl(newUrl);
      if (context.mounted) {
        context.showSnackBar('Server host updated to $newUrl');
      }
    }
  }

  Future<void> _editGeminiApiKey(BuildContext context, WidgetRef ref, String? currentKey) async {
    final controller = TextEditingController(text: currentKey ?? '');
    final newKey = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Google Gemini AI Key', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Obtain a free Gemini API key from Google AI Studio (aistudio.google.com). When not provided, the app uses its comprehensive offline Indian safety & legal engine.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'API Key (AIzaSy...)',
                hintText: 'Enter API key',
              ),
            ),
          ],
        ),
        actions: [
          if (currentKey != null && currentKey.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(ctx, ''),
              child: const Text('Remove Key', style: TextStyle(color: Colors.redAccent)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: const Text('Save Key'),
          ),
        ],
      ),
    );

    if (newKey != null) {
      await ref.read(safetySettingsProvider.notifier).setGeminiApiKey(newKey.isEmpty ? null : newKey);
      if (context.mounted) {
        context.showSnackBar(newKey.isEmpty ? 'Gemini API Key removed. Offline engine active.' : 'Gemini AI Key saved successfully.');
      }
    }
  }

  Future<void> _clearCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF181824),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text('Clear Local Cache?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: const Text(
              'This will evict locally cached OpenStreetMap tiles and journey breadcrumbs. Your emergency contacts and medical card will be preserved.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900),
                child: const Text('Clear Cache'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tracking_journey_history');
      if (context.mounted) {
        context.showSnackBar('Map and journey cache cleared.');
      }
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy & Cryptographic Policy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            'NIRBHAYA PRIVACY DISCLOSURE:\n\n'
            '1. Zero Third-Party Tracking: Nirbhaya never sells or monetizes personal locations, health data, or emergency alerts.\n\n'
            '2. End-to-End Distress Transmission: Live GPS coordinates are shared strictly with your designated emergency contacts and verified emergency dispatch APIs.\n\n'
            '3. On-Device Vault: Offline medical records and recorded evidence are stored in device sandboxed storage and only synced when explicitly authorized.\n\n'
            '4. Permissions: Location, Camera, and Microphone access are utilized solely for emergency dispatch, incident reporting, and safety verification.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181824),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Terms of Safety Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            'TERMS OF SERVICE:\n\n'
            '1. Emergency Use: Nirbhaya is designed as a companion safety tool. In immediate life-threatening situations, always call national emergency services (112) directly.\n\n'
            '2. False Alarms: Intentional misuse or spamming of emergency SOS alerts to public authorities may violate regional penal codes.\n\n'
            '3. Network Dependencies: While offline fallbacks operate via cellular SMS and dialer intents, cloud dispatch features require mobile data or Wi-Fi connectivity.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: const Text('Agree'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(safetySettingsProvider);
    final settingsNotifier = ref.read(safetySettingsProvider.notifier);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF09080F),
      appBar: const AppHeader(title: 'Settings', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // App Signature Branding Header
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(21),
                    child: Image.asset(
                      'assets/images/Nirbhaya-Emblem.png',
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'NIRBHAYA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Fearless Protection & Emergency Assistance',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),

          // 1. SECURITY & PRIVACY
          _buildSectionHeader('Security & Privacy'),
          _buildCard([
            SwitchListTile(
              title: const Text('Biometric Authentication', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Require Fingerprint / Face Unlock on launch', style: TextStyle(fontSize: 12, color: Colors.white60)),
              value: settings.biometricLock,
              activeColor: const Color(0xFFE11D48),
              secondary: const Icon(Icons.fingerprint, color: Colors.cyanAccent),
              onChanged: (v) => settingsNotifier.setBiometricLock(v),
            ),
            const Divider(height: 1, color: Colors.white10),
            ListTile(
              title: const Text('Safety PIN Code', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                settings.pinCode != null ? 'Security PIN active (••••)' : 'Not configured (tap to set 4-digit code)',
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
              leading: const Icon(Icons.pin, color: Colors.amberAccent),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _editPinCode(context, ref, settings.pinCode),
            ),
            const Divider(height: 1, color: Colors.white10),
            SwitchListTile(
              title: const Text('Stealth De-Escalation Mode', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Discreetly triggers silent SOS alerts with screen dimming', style: TextStyle(fontSize: 12, color: Colors.white60)),
              value: settings.stealthMode,
              activeColor: const Color(0xFFE11D48),
              secondary: const Icon(Icons.visibility_off_outlined, color: Colors.purpleAccent),
              onChanged: (v) => settingsNotifier.setStealthMode(v),
            ),
          ]),

          const SizedBox(height: AppSpacing.md),

          // 2. SOS ALERT PREFERENCES
          _buildSectionHeader('Emergency SOS Preferences'),
          _buildCard([
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Countdown Safety Delay', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE11D48)),
                        ),
                        child: Text('${settings.sosCountdownSeconds} Seconds', style: const TextStyle(color: Color(0xFFFDA4AF), fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Prevents accidental panic trigger by allowing quick cancel window', style: TextStyle(fontSize: 12, color: Colors.white60)),
                  Slider(
                    value: settings.sosCountdownSeconds.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: const Color(0xFFE11D48),
                    inactiveColor: Colors.white12,
                    label: '${settings.sosCountdownSeconds}s',
                    onChanged: (val) => settingsNotifier.setSosCountdown(val.round()),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),
            SwitchListTile(
              title: const Text('Volume Button Emergency Trigger', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Rapidly click volume buttons 3 times to initiate silent SOS', style: TextStyle(fontSize: 12, color: Colors.white60)),
              value: settings.volumeButtonTrigger,
              activeColor: const Color(0xFFE11D48),
              secondary: const Icon(Icons.volume_up_outlined, color: Colors.orangeAccent),
              onChanged: (v) => settingsNotifier.setVolumeButtonTrigger(v),
            ),
            const Divider(height: 1, color: Colors.white10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shake-to-SOS Sensitivity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(
                        settings.shakeSensitivity == 0.0
                            ? 'Disabled'
                            : (settings.shakeSensitivity <= 1.0 ? 'Low' : (settings.shakeSensitivity <= 2.0 ? 'Medium' : 'High')),
                        style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Vigorously shaking device dispatches immediate crisis signal', style: TextStyle(fontSize: 12, color: Colors.white60)),
                  Slider(
                    value: settings.shakeSensitivity,
                    min: 0.0,
                    max: 3.0,
                    divisions: 3,
                    activeColor: Colors.amberAccent,
                    inactiveColor: Colors.white12,
                    onChanged: (val) => settingsNotifier.setShakeSensitivity(val),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),
            SwitchListTile(
              title: const Text('Continuous SOS Haptic Pulse', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Continuous tactile feedback pattern during active distress', style: TextStyle(fontSize: 12, color: Colors.white60)),
              value: settings.hapticFeedback,
              activeColor: const Color(0xFFE11D48),
              secondary: const Icon(Icons.vibration, color: Colors.pinkAccent),
              onChanged: (v) => settingsNotifier.setHapticFeedback(v),
            ),
          ]),

          const SizedBox(height: AppSpacing.md),

          // 3. LOCATION ACCURACY SETTINGS
          _buildSectionHeader('Location Stream Accuracy'),
          _buildCard([
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GPS Polling Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Control sensor accuracy vs device battery conservation', style: TextStyle(fontSize: 12, color: Colors.white60)),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'battery_saver', label: Text('Eco (100m)')),
                      ButtonSegment(value: 'balanced', label: Text('Balanced (25m)')),
                      ButtonSegment(value: 'high', label: Text('High Precision (3m)')),
                    ],
                    selected: {settings.locationAccuracy},
                    onSelectionChanged: (val) => settingsNotifier.setLocationAccuracy(val.first),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Color(0xFFE11D48);
                        }
                        return Colors.white.withValues(alpha: 0.05);
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ]),

          const SizedBox(height: AppSpacing.md),

          // 4. THEME & ACCESSIBILITY
          _buildSectionHeader('Appearance & Accessibility'),
          _buildCard([
            SwitchListTile(
              title: const Text('Dark Mode Appearance', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('High-contrast dark midnight interface', style: TextStyle(fontSize: 12, color: Colors.white60)),
              value: isDark,
              activeColor: const Color(0xFFE11D48),
              secondary: const Icon(Icons.dark_mode_outlined, color: Colors.indigoAccent),
              onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(),
            ),
            const Divider(height: 1, color: Colors.white10),
            SwitchListTile(
              title: const Text('Ultra High-Contrast Mode', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Maximizes element visibility in direct sunlight or glare', style: TextStyle(fontSize: 12, color: Colors.white60)),
              value: settings.highContrast,
              activeColor: const Color(0xFFE11D48),
              secondary: const Icon(Icons.contrast, color: Colors.yellowAccent),
              onChanged: (v) => settingsNotifier.setHighContrast(v),
            ),
            const Divider(height: 1, color: Colors.white10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emergency Font Sizing', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('Scale typography for high-stress readability', style: TextStyle(fontSize: 12, color: Colors.white60)),
                    ],
                  ),
                  DropdownButton<double>(
                    value: settings.fontScale,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    items: const [
                      DropdownMenuItem(value: 1.0, child: Text('Default (1.0x)')),
                      DropdownMenuItem(value: 1.15, child: Text('Medium (1.15x)')),
                      DropdownMenuItem(value: 1.30, child: Text('Large (1.30x)')),
                    ],
                    onChanged: (v) {
                      if (v != null) settingsNotifier.setFontScale(v);
                    },
                  ),
                ],
              ),
            ),
          ]),

          const SizedBox(height: AppSpacing.md),

          // 5. CONNECTIVITY & AI ASSISTANT
          _buildSectionHeader('Connectivity & AI Engine'),
          _buildCard([
            ListTile(
              title: const Text('REST API Server URL', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(settings.serverUrl, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.white60)),
              leading: const Icon(Icons.cloud_outlined, color: Colors.lightBlueAccent),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: () => _editServerUrl(context, ref, settings.serverUrl),
            ),
            const Divider(height: 1, color: Colors.white10),
            ListTile(
              title: const Text('Google Gemini AI Key', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                (settings.geminiApiKey != null && settings.geminiApiKey!.isNotEmpty)
                    ? 'Configured (••••••••••••${settings.geminiApiKey!.substring(settings.geminiApiKey!.length > 4 ? settings.geminiApiKey!.length - 4 : 0)})'
                    : 'Not configured (using built-in offline legal/safety engine)',
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
              leading: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: () => _editGeminiApiKey(context, ref, settings.geminiApiKey),
            ),
          ]),

          const SizedBox(height: AppSpacing.md),

          // 6. DATA & STORAGE
          _buildSectionHeader('Storage & Cache'),
          _buildCard([
            ListTile(
              title: const Text('Clear Temporary Cache', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Evict cached map tiles and historical GPS breadcrumbs', style: TextStyle(fontSize: 12, color: Colors.white60)),
              leading: const Icon(Icons.cleaning_services_outlined, color: Colors.deepOrangeAccent),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _clearCache(context),
            ),
          ]),

          const SizedBox(height: AppSpacing.md),

          // 7. ABOUT & LEGAL
          _buildSectionHeader('About & Legal Disclosures'),
          _buildCard([
            const ListTile(
              title: Text('Version & Build'),
              subtitle: Text('1.0.0+1 (Production Release)'),
              leading: Icon(Icons.verified_outlined, color: Colors.tealAccent),
            ),
            const Divider(height: 1, color: Colors.white10),
            ListTile(
              title: const Text('Privacy Policy'),
              subtitle: const Text('Read our zero-tracking data disclosure', style: TextStyle(fontSize: 12, color: Colors.white60)),
              leading: const Icon(Icons.privacy_tip_outlined, color: Colors.greenAccent),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _showPrivacyPolicy(context),
            ),
            const Divider(height: 1, color: Colors.white10),
            ListTile(
              title: const Text('Terms of Safety Service'),
              subtitle: const Text('Crisis dispatch usage & legal terms', style: TextStyle(fontSize: 12, color: Colors.white60)),
              leading: const Icon(Icons.description_outlined, color: Colors.cyanAccent),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _showTermsOfService(context),
            ),
          ]),

          const SizedBox(height: AppSpacing.xl),

          // Account Logout / Switch
          ElevatedButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout / Switch Safety Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.15),
              foregroundColor: Colors.redAccent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.sm),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFDA4AF),
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 0,
      color: const Color(0xFF14131E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
