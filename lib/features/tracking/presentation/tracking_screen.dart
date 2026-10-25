import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nirbhaya/app/theme.dart';
import 'package:nirbhaya/shared/extensions/context_extensions.dart';
import 'package:nirbhaya/shared/widgets/app_header.dart';
import 'package:nirbhaya/features/tracking/domain/tracking_model.dart';
import 'package:nirbhaya/features/tracking/providers/tracking_provider.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = ((seconds % 3600) ~/ 60);
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _shareLiveLocation(TrackingState state, BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final pos = state.currentPosition;
    if (pos == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Waiting for GPS coordinates...'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a').format(now);
    final mapLink = 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
    final text = 'I am tracking my journey on Nirbhaya. My live location at $timeStr: $mapLink';

    final uri = Uri.parse('sms:?body=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Location link copied: $mapLink'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackingProvider);
    final notifier = ref.read(trackingProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Journey Tracking'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!state.isTracking)
                      _buildStartJourneyCard(context, notifier)
                    else
                      _buildActiveJourneyCard(context, state, notifier),

                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'Past Journeys',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (state.history.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            'No recorded journeys yet.',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      )
                    else
                      ...state.history.map(
                        (journey) => _buildHistoryCard(context, journey),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartJourneyCard(
    BuildContext context,
    TrackingNotifier notifier,
  ) {
    return Card(
      elevation: 0,
      color: const Color(0xFF18181B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.base),
        side: const BorderSide(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.navigation_outlined,
                size: 48,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Real-Time Journey Tracking',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Continuously logs GPS waypoints and lets you broadcast live location updates with a single tap.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => notifier.startJourney(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Journey'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveJourneyCard(
    BuildContext context,
    TrackingState state,
    TrackingNotifier notifier,
  ) {
    return Card(
      elevation: 0,
      color: const Color(0xFF18181B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.base),
        side: BorderSide(color: context.colorScheme.primary.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                _buildPulsingDot(),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Live Journey Active',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _formatDuration(state.elapsedDuration),
              style: context.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (state.currentPosition != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(AppRadius.base),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.greenAccent,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lat: ${state.currentPosition!.latitude.toStringAsFixed(5)}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Lng: ${state.currentPosition!.longitude.toStringAsFixed(5)}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Waypoints',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                        Text(
                          '${state.currentJourney?.waypoints.length ?? 0}',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareLiveLocation(state, context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.lightBlueAccent,
                      side: const BorderSide(color: Colors.lightBlueAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.share_location),
                    label: const Text('Share Live Location'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => notifier.stopJourney(),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.stop),
                    label: const Text('End Journey'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withValues(alpha: value),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.5),
                blurRadius: 8 * value,
                spreadRadius: 2 * value,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, Journey journey) {
    final duration = journey.endTime != null
        ? journey.endTime!.difference(journey.startTime)
        : const Duration(seconds: 0);

    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Card(
      elevation: 0,
      color: const Color(0xFF18181B),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.base),
        side: const BorderSide(color: Colors.white10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          child: const Icon(Icons.check, color: Colors.green, size: 20),
        ),
        title: Text(
          dateFormat.format(journey.startTime),
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Duration: ${_formatDuration(duration.inSeconds)} • ${journey.waypoints.length} waypoints',
          style: context.textTheme.bodySmall?.copyWith(color: Colors.white54),
        ),
      ),
    );
  }
}
