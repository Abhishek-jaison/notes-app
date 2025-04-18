import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drivenotes/features/auth/data/repositories/auth_repository_impl.dart';

abstract class AuthRepository {
  Future<bool> signInWithGoogle();
  Future<void> signOut();
  Future<bool> isSignedIn();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});
