import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/features/dashboard/providers/dashboard_provider.dart';
import 'package:nirbhaya/features/dashboard/domain/dashboard_model.dart';
import 'package:nirbhaya/shared/extensions/context_extensions.dart';

class DashboardStatsWidget extends ConsumerWidget {
  const DashboardStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardProvider);

    return statsAsync.when(
      data: (stats) => _buildStatsRow(context, stats),
      loading: () => _buildLoadingShimmer(),
      error: (error, stack) => _buildErrorCard(context, ref, error),
    );
  }

  Widget _buildStatsRow(BuildContext context, UserStats stats) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.security_rounded,
            iconColor: Colors.redAccent,
            count: stats.sosCount,
            label: 'SOS Calls',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.assignment_late_rounded,
            iconColor: Colors.orangeAccent,
            count: stats.incidentsCount,
            label: 'Incidents',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.people_alt_rounded,
            iconColor: Colors.blueAccent,
            count: stats.contactsCount,
            label: 'Contacts',
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF18181B), // Dark card color
                borderRadius: BorderRadius.circular(12.8), // AppRadius.base
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref, Object error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(12.8),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(height: 8),
          Text(
            'Failed to load stats',
            style: context.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          TextButton(
            onPressed: () => ref.read(dashboardProvider.notifier).loadStats(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(12.8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
