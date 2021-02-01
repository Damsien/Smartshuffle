import 'package:flutter/material.dart';

import 'View/GlobalApp.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  //Indispensable pour google sign in
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(new GlobalAppMain());
}
