import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:nirbhaya/app/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Navigate to Home screen after animated brand entrance
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09080F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient background glow
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              final scale = 1.0 + (_glowController.value * 0.15);
              final opacity = 0.25 + (_glowController.value * 0.15);
              return Center(
                child: Container(
                  width: 320 * scale,
                  height: 320 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFE11D48).withValues(alpha: opacity),
                        const Color(0xFF7C3AED).withValues(alpha: opacity * 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Central Animated Brand Cluster
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Signature Logo Emblem
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.4),
                        blurRadius: 28,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.asset(
                      'assets/images/Nirbhaya-Emblem.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                    )
                    .shimmer(
                      delay: 900.ms,
                      duration: 1200.ms,
                      color: Colors.white24,
                    ),

                const SizedBox(height: AppSpacing.lg),

                // App Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFFDA4AF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Text(
                    'NIRBHAYA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.5,
                      color: Colors.white,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 600.ms)
                    .slideY(begin: 0.35, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.xs),

                // Tagline / Subtitle
                const Text(
                  'FEARLESS  •  PROTECTED  •  EMPOWERED',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE2E8F0),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, duration: 500.ms),
              ],
            ),
          ),

          // Bottom Security Badge & Loading Indicator
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Column(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFFE11D48).withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'End-to-End Encrypted Safety Network',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.5,
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 800.ms, duration: 600.ms),
          ),
        ],
      ),
    );
  }
}

