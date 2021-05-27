import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';

class PlatformsConnection {
  static getView(ServicesLister service) {
    if (service == ServicesLister.YOUTUBE)
      return PlatformsConnection._genericButton(PlatformsLister.platforms[ServicesLister.YOUTUBE],
       "Connecter Youtube", AssetImage("assets/logo/youtube_logo.png"), Colors.red[500], Colors.red[200]);
    else if (service == ServicesLister.SPOTIFY)
      return PlatformsConnection._genericButton(PlatformsLister.platforms[ServicesLister.SPOTIFY],
       "Connecter Spotify", AssetImage("assets/logo/spotify_logo.png"), Colors.green[800], Colors.green[200]);
    else
      return Container();
  }

  //Platform button

  static Widget _genericButton(PlatformsController ctrl, String buttonText, ImageProvider image, Color color1, Color color2) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
            color: color1,
            child: OutlineButton(
              splashColor: color2,
              onPressed: () => ctrl.connect(),
              highlightElevation: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                        image: image,
                        height: 30.0),
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
