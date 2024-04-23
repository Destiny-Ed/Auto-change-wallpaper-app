import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:wallpaper_app/configs/enums.dart';

abstract class _AppAuthentication {
  Future<UserCredential?> googleSignIn();
  Future<UserCredential> appleSignIn();
  Future<void> signOut();
}

class AuthProvider extends ChangeNotifier implements _AppAuthentication {
  ViewState viewState = ViewState.idle;

  @override
  Future<UserCredential> appleSignIn() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final authResponse = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

    if (authResponse.user == null) {
      ///error
      viewState = ViewState.error;
    } else {
      viewState = ViewState.success;
    }
    notifyListeners();
    // Once signed in, return the UserCredential
    return authResponse;
  }

  @override
  Future<UserCredential?> googleSignIn() async {
    viewState = ViewState.busy;
    notifyListeners();
    // Trigger the authentication flow
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final authResponse = await FirebaseAuth.instance.signInWithCredential(credential);

      if (googleAuth == null) {
        ///error
        viewState = ViewState.error;
      } else {
        viewState = ViewState.success;
      }
      notifyListeners();

      print("got it oooo $authResponse");
      // Once signed in, return the UserCredential
      return authResponse;
    } catch (e) {
      viewState = ViewState.error;
      notifyListeners();

      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    await GoogleSignIn().signOut();
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
