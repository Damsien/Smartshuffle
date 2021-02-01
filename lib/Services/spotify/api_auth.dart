import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class APIAuth {
  static String _scopes =
      "user-read-private,user-read-email, playlist-read-private,user-modify-playback-state,user-read-playback-state";
  static final storage = new FlutterSecureStorage();

  static Future<String> login() async {
    await DotEnv().load('.env');
    String clientId = DotEnv().env['SPOTIFY_ID'];
    String redirectUri = DotEnv().env['SPOTIFY_URI'];

    String token = await SpotifySdk.getAuthenticationToken(
        clientId: clientId, redirectUrl: redirectUri, scope: _scopes);
    storage.write(key: "SpotifyToken", value: token);
    return token;
  }

  static Future<bool> logout() async {
    //TODO:Effacer le token quand il sera sauvegarder
    await storage.delete(key: "SpotifyToken");
    return false;
  }
}
