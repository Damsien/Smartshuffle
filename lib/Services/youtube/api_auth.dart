import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class APIAuth {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/youtube',
    'https://www.googleapis.com/auth/youtube.force-ssl',
    'https://www.googleapis.com/auth/youtube.readonly',
    'https://www.googleapis.com/auth/youtubepartner-channel-audit'
  ]);
  static bool _isSigningIn = false;
  static GoogleSignInAccount _user;
  static GoogleSignInAuthentication _auth;

  bool get isSigningIn => _isSigningIn;

  static Future<Map<String, GoogleSignInAccount>> login() async {
    _isSigningIn = true;

    _user = await _googleSignIn.signIn();
    if (_user == null) {
      _isSigningIn = false;
      return null;
    } else {
      _auth = await _user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: _auth.accessToken,
        idToken: _auth.idToken,
      );

      try {
        UserCredential cred =
            await FirebaseAuth.instance.signInWithCredential(credential);
      } catch (e) {
        print(e);
      }
      _isSigningIn = false;
      return {_auth.accessToken: _user};
    }
  }

  static Future<bool> logout() async {
    await _googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
    return false;
  }
}
