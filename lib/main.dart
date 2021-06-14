
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:smartshuffle/View/GlobalApp.dart';

void main() async {
  //Indispensable pour google sign in
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(new GlobalAppMain());
}
