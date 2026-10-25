import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:nirbhaya/features/notifications/providers/notifications_provider.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? extraActions;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
          elevation: 0,
          leading: showBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                )
              : null,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!showBack) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/Nirbhaya-Emblem.png',
                    width: 26,
                    height: 26,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            ...?extraActions,
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/notifications'),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const CircleAvatar(
                radius: 14,
                child: Icon(Icons.person, size: 18),
              ),
              onPressed: () => context.push('/profile'),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
