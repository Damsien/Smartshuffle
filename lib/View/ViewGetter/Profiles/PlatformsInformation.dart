import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Util.dart';

class PlatformsInformation {



  static getView(ServicesLister service) {
    if(service != null && service != ServicesLister.DEFAULT) return PlatformsInformation._genericInformations(PlatformsLister.platforms[service], PlatformsLister.platforms[service].platform.name);
    else return Container();
  }


  static Widget _genericInformations(PlatformsController ctrl, String serviceName) {
    var name = ctrl.userInformations['name'];
    var account = ctrl.userInformations['email'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
                children: [
                  Image(image: AssetImage(ctrl.userInformations['logo']), height: 30.0),
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
            Container(
              width: MediaQuery.of(StatesManager.states['ProfilePage'].context).size.width*0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nom : $name", style: TextStyle(fontSize: 20)),
                  Text("Compte : $account", style: TextStyle(fontSize: 20))
                ],
              )
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(right: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 55,
              color: Colors.red,
              child: MaterialButton(
                height: 48,
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