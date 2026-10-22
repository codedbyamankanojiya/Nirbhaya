import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/app/theme.dart';
import 'package:nirbhaya/app/router.dart';
import 'package:nirbhaya/features/settings/providers/theme_provider.dart';

import 'package:nirbhaya/features/auth/providers/auth_providers.dart';

class NirbhayaApp extends ConsumerStatefulWidget {
  const NirbhayaApp({super.key});

  @override
  ConsumerState<NirbhayaApp> createState() => _NirbhayaAppState();
}

class _NirbhayaAppState extends ConsumerState<NirbhayaApp> {
  @override
  void initState() {
    super.initState();
    // Attempt session restoration in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Nirbhaya',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
