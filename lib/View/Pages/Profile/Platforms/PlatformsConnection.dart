import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformsConnection {


  //Connection functions




  //Platforms buttons

  static Widget spotifyButton() {
    String buttonText = "Connecter Spotify";

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        color: Colors.green[800],
        child: OutlineButton(
          splashColor: Colors.green[200],
          onPressed: () {},
          highlightElevation: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(image: AssetImage("assets/logo/spotify_logo.png"), height: 30.0),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      )
    );
  }


  static Widget youtubeButton() {
    String buttonText = "Connecter Youtube";

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        color: Colors.red[500],
        child: OutlineButton(
          splashColor: Colors.red[200],
          onPressed: () {},
          highlightElevation: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(image: AssetImage("assets/logo/youtube_logo.png"), height: 30.0),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      )
    );
  }




}