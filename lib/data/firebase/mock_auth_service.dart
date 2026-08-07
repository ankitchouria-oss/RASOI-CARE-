import 'auth_service.dart';

/// Used automatically whenever Firebase hasn't been configured (the default,
/// out-of-the-box state — see main.dart). Keeps the original demo flow: any
/// phone number "sends", and the code is always 4402, matching the OTP
/// screen's auto-fill affordance.
class MockAuthService implements AuthService {
  static const demoCode = '4402';
  bool _signedIn = false;
  String? _phone;

  @override
  bool get isLive => false;

  @override
  bool get isSignedIn => _signedIn;

  @override
  String? get currentPhone => _signedIn ? _phone : null;

  @override
  Future<OtpSent> sendOtp(String e164Phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _phone = e164Phone;
    return const OtpSent('mock-verification-id');
  }

  @override
  Future<void> verifyOtp(
      {required String verificationId, required String smsCode}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (smsCode != demoCode) {
      throw const AuthException(
          'That code doesn\'t match. Check and try again.');
    }
    _signedIn = true;
  }

  @override
  Future<GoogleProfile> signInWithGoogle() async {
    // Mirrors the demo account shown in the HTML prototype's account picker,
    // so the two stay consistent.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _signedIn = true;
    _phone ??=
        '+91-google-signin'; // no phone number from Google — stays a customer
    return const GoogleProfile(
      displayName: 'Rohan Deshpande',
      email: 'rohan.deshpande@gmail.com',
    );
  }

  @override
  Future<void> signOut() async {
    _signedIn = false;
    _phone = null;
  }
}
