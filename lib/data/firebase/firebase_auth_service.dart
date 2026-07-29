import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_service.dart';

/// Real phone-OTP auth via Firebase. Only ever constructed after
/// `Firebase.initializeApp()` has succeeded — see main.dart.
class FirebaseAuthService implements AuthService {
  final _auth = FirebaseAuth.instance;
  final _google = GoogleSignIn(scopes: ['email']);

  @override
  bool get isLive => true;

  @override
  bool get isSignedIn => _auth.currentUser != null;

  @override
  Future<OtpSent> sendOtp(String e164Phone) {
    final completer = Completer<OtpSent>();
    _auth.verifyPhoneNumber(
      phoneNumber: e164Phone,
      timeout: const Duration(seconds: 60),
      // Some Android devices can verify without the user typing anything
      // (SMS Retriever / instant verification). When that happens we sign
      // in immediately and hand back a synthetic "already done" id so the
      // OTP screen can skip straight past.
      verificationCompleted: (credential) async {
        try {
          await _auth.signInWithCredential(credential);
          if (!completer.isCompleted) completer.complete(const OtpSent('auto-verified'));
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(AuthException(_friendly(e)));
          }
        }
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(AuthException(_friendly(e)));
        }
      },
      codeSent: (verificationId, _) {
        if (!completer.isCompleted) completer.complete(OtpSent(verificationId));
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    return completer.future;
  }

  @override
  Future<void> verifyOtp({required String verificationId, required String smsCode}) async {
    if (verificationId == 'auto-verified') return; // already signed in above
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    }
  }

  @override
  Future<GoogleProfile> signInWithGoogle() async {
    try {
      final account = await _google.signIn();
      if (account == null) {
        // Person closed the picker without choosing anything.
        throw const AuthException('Sign-in was cancelled.');
      }
      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      return GoogleProfile(
        displayName: user?.displayName ?? account.displayName ?? 'there',
        email: user?.email ?? account.email,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendly(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException('Google sign-in failed. Try again.');
    }
  }

  @override
  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  String _friendly(Object e) {
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'invalid-verification-code' => 'That code doesn\'t match. Check and try again.',
        'invalid-phone-number' => 'That doesn\'t look like a valid phone number.',
        'too-many-requests' => 'Too many attempts — wait a bit before retrying.',
        'session-expired' => 'That code expired. Request a new one.',
        'account-exists-with-different-credential' =>
          'That email is already linked to a different sign-in method.',
        _ => e.message ?? 'Something went wrong verifying that number.',
      };
    }
    return 'Something went wrong verifying that number.';
  }
}
