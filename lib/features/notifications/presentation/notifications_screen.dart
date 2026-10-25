import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/notifications_provider.dart';
import '../domain/notification_model.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../app/theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'EMERGENCY':
        return Icons.warning_amber_rounded;
      case 'INCIDENT':
        return Icons.report_problem_outlined;
      case 'SECURITY':
        return Icons.security_outlined;
      case 'ACCOUNT':
        return Icons.person_outline;
      case 'SYSTEM':
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForType(String type, BuildContext context) {
    switch (type.toUpperCase()) {
      case 'EMERGENCY':
        return context.colorScheme.error;
      case 'INCIDENT':
        return Colors.orange;
      case 'SECURITY':
        return Colors.blue;
      case 'ACCOUNT':
        return Colors.green;
      case 'SYSTEM':
      default:
        return context.colorScheme.onSurfaceVariant;
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  String _getGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Today';
    } else if (itemDate == yesterday) {
      return 'Yesterday';
    } else {
      return 'Earlier';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Notifications',
              extraActions: [
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      final scaffold = ScaffoldMessenger.of(context);
                      ref.read(notificationsProvider.notifier).markAllAsRead().catchError((e) {
                        scaffold.showSnackBar(
                          SnackBar(
                            content: Text('Failed to mark all as read: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      });
                    },
                    child: const Text('Mark all read'),
                  ),
              ],
            ),
            Expanded(
              child: notificationsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error', style: TextStyle(color: context.colorScheme.error)),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () => ref.read(notificationsProvider.notifier).loadNotifications(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 64, color: context.colorScheme.onSurfaceVariant),
                          const SizedBox(height: AppSpacing.md),
                          Text('No notifications', style: context.textTheme.titleMedium),
                        ],
                      ),
                    );
                  }

                  final Map<String, List<NotificationItem>> grouped = {
                    'Today': [],
                    'Yesterday': [],
                    'Earlier': [],
                  };

                  for (final n in notifications) {
                    grouped[_getGroup(n.createdAt)]!.add(n);
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref.read(notificationsProvider.notifier).loadNotifications(),
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        for (final group in grouped.keys)
                          if (grouped[group]!.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.sm),
                              child: Text(
                                group,
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: context.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...grouped[group]!.map((notification) {
                              return Dismissible(
                                key: Key(notification.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) {
                                  final scaffold = ScaffoldMessenger.of(context);
                                  ref.read(notificationsProvider.notifier).deleteNotification(notification.id).catchError((e) {
                                    scaffold.showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to delete notification: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  });
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.error,
                                    borderRadius: BorderRadius.circular(AppRadius.base),
                                  ),
                                  child: Icon(Icons.delete, color: context.colorScheme.onError),
                                ),
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.base),
                                    side: BorderSide(
                                      color: notification.isRead ? Colors.transparent : context.colorScheme.primary.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  color: notification.isRead ? const Color(0xFF18181B) : const Color(0xFF18181B).withValues(alpha: 0.8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(AppRadius.base),
                                    onTap: notification.isRead ? null : () {
                                      final scaffold = ScaffoldMessenger.of(context);
                                      ref.read(notificationsProvider.notifier).markAsRead(notification.id).catchError((e) {
                                        scaffold.showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to mark as read: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: _getColorForType(notification.type, context).withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _getIconForType(notification.type),
                                              color: _getColorForType(notification.type, context),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        notification.title,
                                                        style: context.textTheme.titleMedium?.copyWith(
                                                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: AppSpacing.sm),
                                                    Text(
                                                      _formatTime(notification.createdAt),
                                                      style: context.textTheme.bodySmall?.copyWith(
                                                        color: context.colorScheme.onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  notification.message,
                                                  style: context.textTheme.bodyMedium?.copyWith(
                                                    color: notification.isRead 
                                                      ? context.colorScheme.onSurfaceVariant
                                                      : context.colorScheme.onSurface,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!notification.isRead) ...[
                                            const SizedBox(width: AppSpacing.sm),
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(top: 8),
                                              decoration: BoxDecoration(
                                                color: context.colorScheme.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
