import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';

class PlatformsConnection {
  static getView(ServicesLister service, String buttonString) {
    if (service != null && service != ServicesLister.DEFAULT)
      return PlatformsConnection._genericButton(PlatformsLister.platforms[service],
       buttonString, AssetImage(PlatformsLister.platforms[service].platform.platformInformations['logo']),
       PlatformsLister.platforms[service].platform.platformInformations['main_color'], PlatformsLister.platforms[service].platform.platformInformations['secondary_color']);
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
