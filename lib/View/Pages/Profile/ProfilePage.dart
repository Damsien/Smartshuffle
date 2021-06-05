import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/ProfileView.dart';


class ProfilePage extends StatefulWidget {

  final String title;
  final MaterialColor materialColor;
  
  ProfilePage({Key key, this.title, this.materialColor}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  Key key = UniqueKey();

  @override
    bool get wantKeepAlive => true;

  Widget getPlatforms(MapEntry plat) {
    Widget platform;
    if(plat.value.getUserInformations()['isConnected'] == false)
      platform = plat.value.getView(service: plat.key, view: ProfileViewType.PlatformConnection,
       parameters: {'buttonString': AppLocalizations.of(context).globalConnect+" "+plat.value.platform.name});
    else
      platform = plat.value.getView(service: plat.key, view: ProfileViewType.PlatformInformation);
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
    for(MapEntry plat in PlatformsLister.platforms.entries) {
      plat.value.setProfilePageState(this);
    }

    return MaterialApp(
      key: this.key,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: this.widget.materialColor,
        accentColor: this.widget.materialColor.shade100,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).globalTitleProfile),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black54,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
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
                  FormSuggestion(materialColor: this.widget.materialColor),
                  Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 40),
                    child: Container(
                      height: 1,
                      color: Colors.white,
                    )
                  ),
                  InkWell(
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationVersion: '1.0.0',
                        applicationName: 'SmartShuffle'
                      );
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