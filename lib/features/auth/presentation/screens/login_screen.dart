import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drivenotes/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      next.whenData((isSignedIn) {
        if (isSignedIn) {
          context.go('/notes');
        }
      });
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'DriveNotes',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            if (authState.isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).signInWithGoogle();
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
              ),
            if (authState.hasError) ...[
              const SizedBox(height: 16),
              Text(
                'Error: ${authState.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
