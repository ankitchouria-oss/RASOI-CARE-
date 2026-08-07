// The seam between the auth screens and whichever phone-auth backend is
// live. FirebaseAuthService and MockAuthService both implement this; the
// screens only ever talk to AuthService, never to Firebase directly.

/// Outcome of requesting an OTP.
class OtpSent {
  const OtpSent(this.verificationId);
  final String verificationId;
}

/// Basic profile handed back after a successful Google sign-in — enough for
/// the UI to greet the person and skip the manual registration form, since
/// Google already verified their name and email.
class GoogleProfile {
  const GoogleProfile({required this.displayName, required this.email});
  final String displayName;
  final String email;
}

abstract interface class AuthService {
  /// True once real Firebase phone auth is backing this instance. The OTP
  /// screen uses this to decide whether to show the "auto-fill" demo affordance
  /// (mock only) or ask the person to type the SMS code they actually received.
  bool get isLive;

  /// Whether a user is currently signed in (checked once at app start).
  bool get isSignedIn;

  /// The signed-in person's phone number in E.164 form, or null if signed
  /// out (or signed in via Google, which carries no phone number). This is
  /// what role resolution keys off — see [CareRepository.roleForPhone].
  String? get currentPhone;

  /// Sends the OTP. Throws an [AuthException] on failure.
  Future<OtpSent> sendOtp(String e164Phone);

  /// Verifies the code against the most recent [OtpSent.verificationId].
  /// Throws an [AuthException] if it doesn't match.
  Future<void> verifyOtp(
      {required String verificationId, required String smsCode});

  /// Google OAuth sign-in. Throws an [AuthException] if the person cancels
  /// the picker or the sign-in otherwise fails.
  Future<GoogleProfile> signInWithGoogle();

  Future<void> signOut();
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
