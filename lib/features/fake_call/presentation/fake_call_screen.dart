import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nirbhaya/app/theme.dart';
import 'package:nirbhaya/shared/extensions/context_extensions.dart';
import 'package:nirbhaya/features/fake_call/providers/fake_call_provider.dart';

class FakeCallScreen extends ConsumerWidget {
  const FakeCallScreen({super.key});

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fakeCallProvider);
    final notifier = ref.read(fakeCallProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          notifier.endCall();
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF09090B),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF18181B),
                Color(0xFF09090B),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Caller Info
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colorScheme.primary.withValues(alpha: 0.2),
                          border: Border.all(
                            color: context.colorScheme.primary.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            state.callerName.isNotEmpty ? state.callerName[0].toUpperCase() : '?',
                            style: context.textTheme.displayMedium?.copyWith(
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        state.callerName,
                        style: context.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        state.isInCall 
                            ? _formatDuration(state.callDuration)
                            : (state.isRinging ? 'Incoming Call...' : 'Calling in ${state.delaySeconds}s...'),
                        style: context.textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: state.isInCall
                      ? _buildInCallControls(context, notifier)
                      : _buildRingingControls(context, state, notifier),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRingingControls(BuildContext context, FakeCallState state, FakeCallNotifier notifier) {
    if (!state.isRinging && !state.isInCall && state.delaySeconds > 0) {
      // Waiting to ring state
      return FloatingActionButton.large(
        onPressed: () {
          notifier.endCall();
          context.pop();
        },
        backgroundColor: Colors.red,
        elevation: 0,
        child: const Icon(Icons.close, color: Colors.white, size: 36),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.large(
              heroTag: 'decline',
              onPressed: () {
                notifier.declineCall();
                context.pop();
              },
              backgroundColor: Colors.red,
              elevation: 0,
              child: const Icon(Icons.call_end, color: Colors.white, size: 36),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Decline', style: context.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.large(
              heroTag: 'accept',
              onPressed: () {
                notifier.acceptCall();
              },
              backgroundColor: Colors.green,
              elevation: 0,
              child: const Icon(Icons.call, color: Colors.white, size: 36),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Accept', style: context.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ],
        ),
      ],
    );
  }

  Widget _buildInCallControls(BuildContext context, FakeCallNotifier notifier) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIconButton(Icons.mic_off_outlined, 'Mute', context),
            _buildIconButton(Icons.dialpad, 'Keypad', context),
            _buildIconButton(Icons.volume_up_outlined, 'Speaker', context),
          ],
        ),
        const SizedBox(height: 40),
        FloatingActionButton.large(
          onPressed: () {
            notifier.endCall();
            context.pop();
          },
          backgroundColor: Colors.red,
          elevation: 0,
          child: const Icon(Icons.call_end, color: Colors.white, size: 36),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, String label, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: context.textTheme.bodySmall?.copyWith(color: Colors.white70)),
      ],
    );
  }
}
