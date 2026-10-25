import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nirbhaya/features/home/presentation/home_screen.dart';
import 'package:nirbhaya/features/maps/presentation/map_screen.dart';
import 'package:nirbhaya/features/ai_assistant/presentation/chat_screen.dart';
import 'package:nirbhaya/features/tracking/presentation/tracking_screen.dart';
import 'package:nirbhaya/features/resources/presentation/resources_screen.dart';
import 'package:nirbhaya/features/profile/presentation/profile_screen.dart';
import 'package:nirbhaya/features/auth/presentation/login_screen.dart';
import 'package:nirbhaya/features/auth/presentation/register_screen.dart';
import 'package:nirbhaya/features/auth/presentation/forgot_password_screen.dart';
import 'package:nirbhaya/features/contacts/presentation/contacts_screen.dart';
import 'package:nirbhaya/features/incidents/presentation/incidents_screen.dart';
import 'package:nirbhaya/features/notifications/presentation/notifications_screen.dart';
import 'package:nirbhaya/features/settings/presentation/settings_screen.dart';
import 'package:nirbhaya/features/fake_call/presentation/fake_call_screen.dart';
import 'package:nirbhaya/features/sos/presentation/sos_active_screen.dart';
import 'package:nirbhaya/features/splash/presentation/splash_screen.dart';
import 'package:nirbhaya/shared/widgets/app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    // Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/assistant',
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tracking',
              builder: (context, state) => const TrackingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/resources',
              builder: (context, state) => const ResourcesScreen(),
            ),
          ],
        ),
      ],
    ),

    // Full-Screen Routes (above bottom nav)
    GoRoute(
      path: '/profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/contacts',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ContactsScreen(),
    ),
    GoRoute(
      path: '/incidents',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const IncidentsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/fake-call',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FakeCallScreen(),
    ),
    GoRoute(
      path: '/sos-active',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SosActiveScreen(),
    ),
  ],
);
