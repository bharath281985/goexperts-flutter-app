import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/network/api_endpoints.dart';

class SocialAuthCancelledException implements Exception {}

class SocialAuthResult {
  const SocialAuthResult({
    required this.provider,
    required this.idToken,
    this.accessToken,
    this.email,
    this.fullName,
  });

  final String provider;
  final String idToken;
  final String? accessToken;
  final String? email;
  final String? fullName;
}

class SocialAuthService {
  SocialAuthService();

  /// Web/server client ID — must match backend GOOGLE_WEB_CLIENT_ID so the
  /// ID token audience can be verified.
  static const googleServerClientId =
      '817575811603-sjk8n64ib4a7mt6nrojjtgg5uhti6j0q.apps.googleusercontent.com';

  final _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    serverClientId: googleServerClientId,
  );

  Future<SocialAuthResult> signInWithGoogle() async {
    // Clear any stale session so we always get a fresh ID token.
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    final account = await _googleSignIn.signIn();
    if (account == null) throw SocialAuthCancelledException();

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Google ID token missing. Check Google Cloud OAuth client configuration.',
      );
    }

    return SocialAuthResult(
      provider: 'google',
      idToken: idToken,
      accessToken: auth.accessToken,
      email: account.email,
      fullName: account.displayName,
    );
  }

  Future<SocialAuthResult> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw Exception('Apple Sign-In is only available on Apple platforms');
    }

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final idToken = credential.identityToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Apple identity token missing');
    }
    final nameParts = [
      credential.givenName,
      credential.familyName,
    ].whereType<String>().where((part) => part.trim().isNotEmpty);
    return SocialAuthResult(
      provider: 'apple',
      idToken: idToken,
      email: credential.email,
      fullName: nameParts.isEmpty ? null : nameParts.join(' '),
    );
  }

  String endpointForProvider(String provider) {
    switch (provider) {
      case 'google':
        return ApiEndpoints.socialGoogle;
      case 'apple':
        return ApiEndpoints.socialApple;
      default:
        throw Exception('Unsupported provider: $provider');
    }
  }
}
