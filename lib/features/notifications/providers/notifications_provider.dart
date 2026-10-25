import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/notification_model.dart';
import '../data/notifications_api.dart';
import '../../../features/auth/providers/auth_providers.dart';

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  return NotificationsApi(ref.watch(apiClientProvider));
});

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationItem>>>((ref) {
  return NotificationsNotifier(ref.watch(notificationsApiProvider));
});

final unreadCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationsProvider);
  return state.maybeWhen(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  final NotificationsApi _api;

  NotificationsNotifier(this._api) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  int get unreadCount {
    return state.maybeWhen(
      data: (notifications) => notifications.where((n) => !n.isRead).length,
      orElse: () => 0,
    );
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getNotifications();
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data;
        final notifications = data.map((e) => NotificationItem.fromJson(e)).toList();
        state = AsyncValue.data(notifications);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await _api.markAsRead(id);
      if (response.success) {
        state = state.whenData((notifications) {
          return notifications.map((n) {
            if (n.id == id) {
              return n.copyWith(isRead: true, readAt: DateTime.now());
            }
            return n;
          }).toList();
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _api.markAllAsRead();
      if (response.success) {
        state = state.whenData((notifications) {
          final now = DateTime.now();
          return notifications.map((n) => n.copyWith(isRead: true, readAt: n.readAt ?? now)).toList();
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final response = await _api.deleteNotification(id);
      if (response.success) {
        state = state.whenData((notifications) {
          return notifications.where((n) => n.id != id).toList();
        });
      }
    } catch (e) {
      rethrow;
    }
  }
}
