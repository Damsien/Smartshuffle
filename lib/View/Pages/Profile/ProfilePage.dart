import 'package:flutter/material.dart';
import 'package:smartshuffle/Controller/PlatformsLister.dart';

class ProfilePageMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile',
      debugShowCheckedModeBanner: false,
      home: new ProfilePage(title: 'Profile'),
    );
  }
}

class ProfilePage extends StatefulWidget {

  final String title;
  
  ProfilePage({Key key, this.title}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {



  Widget getPlatforms(MapEntry plat) {
    var platform;
    if(plat.value.getUserInformations()['isConnected'] == false)
      platform = plat.value.getButtonView();
    else
      platform = plat.value.getInformationView();
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
          for(var plat in PlatformsLister.platforms.entries) getPlatforms(plat)
        ],
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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