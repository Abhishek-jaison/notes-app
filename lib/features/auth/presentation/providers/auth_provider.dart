import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drivenotes/features/auth/domain/repositories/auth_repository.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(false));

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final isSignedIn = await _repository.signInWithGoogle();
      state = AsyncValue.data(isSignedIn);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _repository.signOut();
      state = const AsyncValue.data(false);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
