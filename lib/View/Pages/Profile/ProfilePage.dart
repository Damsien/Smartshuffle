import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Model/Util.dart';

import 'package:smartshuffle/View/ViewGetter/FormsView.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/ProfileView.dart';


class ProfilePage extends StatefulWidget {

  final String title;
  
  ProfilePage({Key key, this.title}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  
  final MaterialColor _materialColor = GlobalTheme.material_color;
  final ThemeData _themeData = GlobalTheme.themeData;

  Key key = UniqueKey();

  @override
    bool get wantKeepAlive => true;

  Widget getPlatforms(MapEntry plat) {
    Widget platform;
    if(plat.value.userInformations['isConnected'] == false)
      platform = ProfileView.getView(service: plat.key, view: ProfileViewType.PlatformConnection,
       parameters: {'buttonString': AppLocalizations.of(context).globalConnect+" "+plat.value.platform.name});
    else
      platform = ProfileView.getView(service: plat.key, view: ProfileViewType.PlatformInformation);
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 20),
      child: platform
    );
  }


  Widget getPlatformsCard() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for(MapEntry plat in PlatformsLister.platforms.entries) getPlatforms(plat)
        ],
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    StatesManager.setProfilePageState(this);

    return MaterialApp(
      key: this.key,
      theme: _themeData,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('fr', ''),
        const Locale('en', ''),
      ],
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black54,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 30, right: 30, top: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10, top: 30),
                    child: Text(AppLocalizations.of(context).connexion, style: TextStyle(fontSize: 35)),
                  ),
                  getPlatformsCard(),
                  Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 40),
                    child: Container(
                      height: 1,
                      color: Colors.white,
                    )
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Text(AppLocalizations.of(context).profileFormTitle, style: TextStyle(fontSize: 35)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).profileHaveSpottedBug, style: TextStyle(fontSize: 17)),
                        Text(AppLocalizations.of(context).profileHaveSuggestion, style: TextStyle(fontSize: 17)),
                      ],
                    )
                  ),
                  Text(AppLocalizations.of(context).profileTellUs, style: TextStyle(fontSize: 17)),
                  FormSuggestion(),
                  Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 40),
                    child: Container(
                      height: 1,
                      color: Colors.white,
                    )
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Theme(
                            data: Theme.of(context).copyWith(backgroundColor: Colors.orange),
                            child: AboutDialog(
                              applicationName: 'SmartShuffle'
                            ),
                          );
                        },
                      );
                      // showAboutDialog(
                      //   context: context,
                      //   applicationVersion: 'beta-1.0',
                      //   applicationName: 'SmartShuffle'
                      // );
                    },
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.info),
                        Text(AppLocalizations.of(context).globalMoreInfo, style: TextStyle(fontSize: 15))
                      ],
                    )
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              )
            )
          )
        )
      )
    );
    
  }
}