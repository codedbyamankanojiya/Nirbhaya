import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:nirbhaya/features/contacts/providers/contacts_provider.dart';
import 'package:nirbhaya/features/sos/domain/sos_state.dart';
import 'package:nirbhaya/features/sos/providers/sos_provider.dart';

class SosActiveScreen extends ConsumerStatefulWidget {
  const SosActiveScreen({super.key});

  @override
  ConsumerState<SosActiveScreen> createState() => _SosActiveScreenState();
}

class _SosActiveScreenState extends ConsumerState<SosActiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  Timer? _durationTimer;
  int _secondsActive = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsActive++;
        });
      }
    });

    _startEmergencyVibration();
  }

  void _startEmergencyVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(pattern: [0, 500, 500, 500], repeat: 0);
      }
    } catch (_) {}
  }

  void _stopEmergencyVibration() {
    try {
      Vibration.cancel();
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _durationTimer?.cancel();
    _durationTimer = null;
    _stopEmergencyVibration();
    WakelockPlus.disable();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _callEmergency(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmergencySms(SosState state) async {
    final contactsState = ref.read(contactsProvider);
    final phoneNumbers = contactsState.maybeWhen(
      data: (contacts) => contacts.map((c) => c.phone).toList(),
      orElse: () => <String>[],
    );

    final lat = state.latitude;
    final lng = state.longitude;
    final locationText = (lat != null && lng != null)
        ? 'Location: https://maps.google.com/?q=$lat,$lng'
        : 'Location unavailable';

    final message = Uri.encodeComponent('EMERGENCY! I need immediate assistance! $locationText');
    final recipients = phoneNumbers.isNotEmpty ? phoneNumbers.join(';') : '';
    final uri = Uri.parse('sms:$recipients?body=$message');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _handleImSafe() async {
    _stopEmergencyVibration();
    await ref.read(sosProvider.notifier).resolveSos();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Distress alert resolved. You are marked safe.'),
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }
  }

  Future<void> _handleCancel() async {
    _stopEmergencyVibration();
    await ref.read(sosProvider.notifier).cancelSos();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF1E1E2C),
          content: Text('Emergency distress cancelled.'),
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(sosProvider);

    // Reactive listener to auto-pop if resolved or idle externally
    ref.listen<SosState>(sosProvider, (previous, next) {
      if (next.status == SosStatus.idle || next.status == SosStatus.resolved) {
        _stopEmergencyVibration();
        if (mounted && context.canPop()) {
          context.pop();
        }
      }
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF1F0404),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Header & Duration
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'EMERGENCY ACTIVE: ${_formatDuration(_secondsActive)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Pulsing SOS Beacon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.35),
                    border: Border.all(color: Colors.redAccent, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.6),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.emergency,
                          color: Colors.white,
                          size: 60,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sosState.status == SosStatus.activating ? 'ACTIVATING...' : 'SOS LIVE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'DISTRESS SIGNAL BROADCAST',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),

              // Live GPS Coordinates Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.gps_fixed,
                      color: Colors.lightGreenAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        (sosState.latitude != null && sosState.longitude != null)
                            ? 'GPS: ${sosState.latitude!.toStringAsFixed(5)}, ${sosState.longitude!.toStringAsFixed(5)}'
                            : 'Acquiring high-accuracy GPS...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Quick Crisis Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    // Call 112
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _callEmergency('112'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.phone),
                        label: const Text(
                          'Call 112',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Send SMS
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendEmergencySms(sosState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.sms),
                        label: const Text(
                          'Send SMS',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Safe / Cancel Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _handleImSafe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          "I am Safe (Resolve SOS)",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _handleCancel,
                      child: const Text(
                        'Cancel Distress Broadcast',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
