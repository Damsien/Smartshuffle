import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/PlatformsConnection.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/PlatformsInformation.dart';


enum ViewType {
  PlatformInformation,
  PlatformConnection,
}

class ViewGetter {

  static getView({@required ServicesLister service, @required ViewType view}) {
    if(view == ViewType.PlatformConnection) return PlatformsConnection.getView(service);
    else if(view == ViewType.PlatformInformation) return PlatformsInformation.getView(service);
  }

}