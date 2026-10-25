import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:nirbhaya/app/theme.dart';
import 'package:nirbhaya/shared/widgets/app_header.dart';
import 'package:nirbhaya/shared/extensions/context_extensions.dart';
import 'package:nirbhaya/features/auth/providers/auth_providers.dart';
import 'package:nirbhaya/features/sos/providers/sos_provider.dart';
import 'package:nirbhaya/features/sos/domain/sos_state.dart';
import 'package:nirbhaya/features/sos/presentation/sos_countdown_overlay.dart';
import 'package:nirbhaya/features/dashboard/presentation/dashboard_stats_widget.dart';
import 'package:nirbhaya/features/uploads/presentation/evidence_capture_dialog.dart';
import 'package:nirbhaya/features/fake_call/presentation/fake_call_setup_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _triggerSos() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.baseRadius),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Activate Emergency SOS?'),
          ],
        ),
        content: const Text(
          'This will immediately:\n'
          '• Share your live GPS location\n'
          '• Alert your emergency contacts\n'
          '• Start a 3-second countdown',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(sosProvider.notifier).triggerSos();
            },
            child: const Text('Activate SOS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final sosState = ref.watch(sosProvider);

    final userName = authState.user?.profile?.name ??
        authState.user?.email.split('@').first ??
        'Guest';
    final isAuthenticated = authState.status == AuthStatus.authenticated;

    // Listen for SOS state changes to navigate
    ref.listen<SosState>(sosProvider, (prev, next) {
      if (next.status == SosStatus.active) {
        context.push('/sos-active');
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppHeader(title: '${_getGreeting()}, $userName'),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Safety Status Card
                  if (!isAuthenticated)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Card(
                        color: AppColors.darkCard,
                        child: ListTile(
                          leading: const Icon(
                            Icons.info_outline,
                            color: Colors.amber,
                          ),
                          title: const Text('Sign in for full protection'),
                          subtitle: const Text(
                            'Login to sync contacts & enable cloud SOS',
                          ),
                          trailing: TextButton(
                            onPressed: () => context.push('/login'),
                            child: const Text('Login'),
                          ),
                        ),
                      ),
                    ),

                  // Dashboard Stats
                  if (isAuthenticated)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: DashboardStatsWidget(),
                    ),

                  const SizedBox(height: AppSpacing.lg),

                  // SOS Button
                  Center(
                    child: GestureDetector(
                      onTap: _triggerSos,
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 208,
                              height: 208,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withValues(alpha: 0.2),
                              ),
                              child: Center(
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.redAccent,
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.emergency,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'SOS',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Press the button to send an SOS alert to your emergency contacts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Quick Access Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      'Quick Access',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.contacts,
                            label: 'Contacts',
                            color: Colors.blue,
                            onTap: () => context.push('/contacts'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.report,
                            label: 'Incidents',
                            color: Colors.orange,
                            onTap: () => context.push('/incidents'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.settings,
                            label: 'Settings',
                            color: Colors.grey,
                            onTap: () => context.push('/settings'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Quick Actions Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  color: context.colorScheme.surface.withValues(alpha: 0.6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionBtn(
                        Icons.phone,
                        'Fake Call',
                        () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.darkCard,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) => const FakeCallSetupDialog(),
                        ),
                      ),
                      _buildActionBtn(
                        Icons.videocam,
                        'Record Evidence',
                        () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.darkCard,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) => const EvidenceCaptureDialog(),
                        ),
                      ),
                      _buildActionBtn(
                        Icons.shield,
                        'Safety Tips',
                        () => context.go('/resources'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SOS Countdown Overlay
          if (sosState.status == SosStatus.countdown ||
              sosState.status == SosStatus.activating)
            const SosCountdownOverlay(),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(16),
              color: context.colorScheme.surface,
            ),
            child: Icon(
              icon,
              size: 28,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.darkCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.baseRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
