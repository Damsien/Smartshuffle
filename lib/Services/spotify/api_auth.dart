import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class APIAuth {
  static String _scopes =
      "user-read-playback-state, user-modify-playback-state, user-read-currently-playing, playlist-modify-public, playlist-modify-private, playlist-read-private, playlist-read-collaborative, user-read-email, user-read-private, user-library-modify, user-library-read";

  static Future<String> login() async {
    await load(fileName: '.env');
    String clientId = env['SPOTIFY_ID'];
    String redirectUri = env['SPOTIFY_URI'];

    String token = await SpotifySdk.getAuthenticationToken(
        clientId: clientId, redirectUrl: redirectUri, scope: _scopes);
    // await SpotifySdk.connectToSpotifyRemote(
    //       clientId: clientId,
    //       redirectUrl: redirectUri);
    // await SpotifySdk.connectToSpotifyRemote(clientId: clientId, redirectUrl: redirectUri, accessToken: token);

    return token;
  }

  static Future<bool> logout() async {
    // await SpotifySdk.disconnect();
    return false;
  }
}
