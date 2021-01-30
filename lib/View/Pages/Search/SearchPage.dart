import 'package:flutter/material.dart';

class SearchPageMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search',
      debugShowCheckedModeBanner: false,
      home: new SearchPage(title: 'Search'),
    );
  }
}

class SearchPage extends StatefulWidget {

  final String title;
  
  SearchPage({Key key, this.title}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
    );
    
  }
}