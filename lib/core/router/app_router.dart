import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drivenotes/features/auth/presentation/screens/login_screen.dart';
import 'package:drivenotes/features/notes/presentation/screens/notes_screen.dart';
import 'package:drivenotes/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:drivenotes/features/notes/domain/entities/note.dart';
import 'package:drivenotes/features/auth/presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/notes', builder: (context, state) => const NotesScreen()),
      GoRoute(
        path: '/notes/new',
        builder: (context, state) => const NoteEditorScreen(),
      ),
      GoRoute(
        path: '/notes/:id',
        builder: (context, state) {
          final note = state.extra as Note;
          return NoteEditorScreen(note: note);
        },
      ),
    ],
    redirect: (context, state) {
      final isSignedIn = authState.value ?? false;
      final isOnLoginPage = state.matchedLocation == '/login';

      if (!isSignedIn && !isOnLoginPage) {
        return '/login';
      }

      if (isSignedIn && isOnLoginPage) {
        return '/notes';
      }

      return null;
    },
  );
});
