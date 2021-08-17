
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/PlatformsConnection.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/PlatformsInformation.dart';


enum ProfileViewType {
  PlatformInformation,
  PlatformConnection,
}

class ProfileView {

  static getView({@required ServicesLister service, @required ProfileViewType view, Map parameters}) {
    if(view == ProfileViewType.PlatformConnection) return PlatformsConnection.getView(service, parameters['buttonString']);
    else if(view == ProfileViewType.PlatformInformation) return PlatformsInformation.getView(service);
  }

}
