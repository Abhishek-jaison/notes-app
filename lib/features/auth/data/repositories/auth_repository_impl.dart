import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:drivenotes/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _storage = const FlutterSecureStorage();
  final _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive.appdata',
    ],
  );

  AuthRepositoryImpl();

  @override
  Future<bool> signInWithGoogle() async {
    try {
      print('Starting Google Sign In process...');
      final account = await _googleSignIn.signIn();
      if (account == null) {
        print('Google Sign In failed: No account returned');
        return false;
      }
      print('Google Sign In successful for account: ${account.email}');

      final auth = await account.authentication;
      final accessToken = auth.accessToken;
      final idToken = auth.idToken;

      if (accessToken == null) {
        print('Google Sign In failed: No access token received');
        return false;
      }
      print('Access token received successfully');

      await _storage.write(key: 'access_token', value: accessToken);
      if (idToken != null) {
        await _storage.write(key: 'id_token', value: idToken);
      }

      // Verify token was stored
      final storedToken = await _storage.read(key: 'access_token');
      if (storedToken == null) {
        print('Error: Token was not stored successfully');
        return false;
      }
      print('Token stored successfully');

      return true;
    } on PlatformException catch (e) {
      print('Platform Exception during sign in: $e');
      return false;
    } catch (e) {
      print('Error during sign in: $e');
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    print('Starting sign out process...');
    await _googleSignIn.signOut();
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'id_token');
    print('Sign out completed');
  }

  @override
  Future<bool> isSignedIn() async {
    final token = await _storage.read(key: 'access_token');
    print(
      'Checking sign in status: ${token != null ? 'Signed in' : 'Not signed in'}',
    );
    return token != null;
  }
}
