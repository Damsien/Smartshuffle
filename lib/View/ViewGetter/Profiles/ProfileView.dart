import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/PlatformsConnection.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/PlatformsInformation.dart';


enum ProfileViewType {
  PlatformInformation,
  PlatformConnection,
}

class ProfileView {

  static getView({@required ServicesLister service, @required ProfileViewType view}) {
    if(view == ProfileViewType.PlatformConnection) return PlatformsConnection.getView(service);
    else if(view == ProfileViewType.PlatformInformation) return PlatformsInformation.getView(service);
  }

}