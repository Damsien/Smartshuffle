import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';

class PlatformsInformation {



  static getView(ServicesLister service) {
    if(service != null && service != ServicesLister.DEFAULT) return PlatformsInformation._genericInformations(PlatformsLister.platforms[service], PlatformsLister.platforms[service].platform.name);
    else return Container();
  }


  static Widget _genericInformations(PlatformsController ctrl, String serviceName) {
    var name = ctrl.getUserInformations()['name'];
    var account = ctrl.getUserInformations()['account'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
                children: [
                  Image(image: AssetImage(ctrl.getPlatformInformations()['logo']), height: 30.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "$serviceName",
                      style: TextStyle(fontSize: 27),
                    ),
                  )
                ]
            ),
            SizedBox(height: 20),
            Text("Nom : $name", style: TextStyle(fontSize: 20)),
            Text("Compte : $account", style: TextStyle(fontSize: 20))
          ],
        ),
        Container(
          margin: EdgeInsets.only(right: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 55,
              color: Colors.red,
              child: OutlineButton(
                splashColor: Colors.red[200],
                highlightElevation: 0,
                onPressed: () => ctrl.disconnect(),
                child: Icon(Icons.link_off, color: Colors.white)
              )
            )
          )
        )
      ]
    );
  }


}