import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noteshelper/core/config/app_theme.dart';
import 'package:noteshelper/providers/auth_provider.dart';
import 'package:noteshelper/screens/auth/login_screen.dart';
import 'package:noteshelper/screens/auth/register_screen.dart';
import 'package:noteshelper/screens/home/home_screen.dart';
import 'package:noteshelper/screens/capture/capture_screen.dart';
import 'package:noteshelper/screens/capture/processing_screen.dart';
import 'package:noteshelper/screens/note_detail/note_detail_screen.dart';
import 'package:noteshelper/screens/mind_map/mind_map_screen.dart';
import 'package:noteshelper/screens/settings/settings_screen.dart';

class NotesHelperApp extends ConsumerWidget {
  const NotesHelperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);

    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = authState.isLoggedIn;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        if (!isLoggedIn && !isAuthRoute) return '/login';
        if (isLoggedIn && isAuthRoute) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/capture',
          builder: (context, state) => const CaptureScreen(),
        ),
        GoRoute(
          path: '/processing',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return ProcessingScreen(
              imagePath: extra?['imagePath'] as String? ?? '',
              provider: extra?['provider'] as String? ?? 'openai',
            );
          },
        ),
        GoRoute(
          path: '/note/:id',
          builder: (context, state) => NoteDetailScreen(
            noteId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/mind-map/:noteId',
          builder: (context, state) => MindMapScreen(
            noteId: state.pathParameters['noteId']!,
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'NotesHelper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
