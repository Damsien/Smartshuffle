import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/View/ViewGetter/ViewGetter.dart';


class ProfilePage extends StatefulWidget {

  final String title;
  
  ProfilePage({Key key, this.title}) : super(key: key);

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
      platform = plat.value.getView(service: plat.key, view: ViewType.PlatformConnection);
    else
      platform = plat.value.getView(service: plat.key, view: ViewType.PlatformInformation);
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(left: 30, bottom: 20),
      child: platform
    );
  }


  Widget getPlatformsCard() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 30, bottom: 30, top: 30),
            child: Text("Connexion", style: TextStyle(fontSize: 35)),
          ),
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
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Profil'),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black54,
          child: SingleChildScrollView(
            child: Column(
              children: [
                getPlatformsCard()
              ],
            ) 
          )
        )
      )
    );
    
  }
}