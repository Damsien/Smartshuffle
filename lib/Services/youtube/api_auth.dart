import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

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
  static var _httpClient;
  static GoogleSignInAuthentication _auth;

  bool get isSigningIn => _isSigningIn;

  static Future<Map<dynamic, GoogleSignInAccount>> login() {
    return _loginWithAllScopes(_googleSignIn);
  }

  static Future<Map<dynamic, GoogleSignInAccount>> _loginWithAllScopes(GoogleSignIn googleSignIn) async {
    _isSigningIn = true;

    _user = await googleSignIn.signIn();
    if (_user == null) {
      _isSigningIn = false;
      return null;
    } else {
      _auth = await _user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: _auth.accessToken,
        idToken: _auth.idToken,
      );

      // try {
      //   UserCredential cred =
      //       await FirebaseAuth.instance.signInWithCredential(credential);
      // } catch (e) {
      //   print(e);
      // }
      _isSigningIn = false;

      _httpClient = await googleSignIn.authenticatedClient();

      return {_httpClient: _user};
    }
  }

  static Future<Map<dynamic, GoogleSignInAccount>> loginWithoutAllScopes() async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: <String>[
    ]);
    if(_user == null) {
      return _loginWithAllScopes(googleSignIn);
    } else {
      return login();
    }
  }

  static Future<bool> logout() async {
    await _googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
    return false;
  }
}
