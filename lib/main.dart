import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //add project details by going to your project settings
    options: FirebaseOptions(
        apiKey: "AIzaSyAlZuxjipX2acMPVvixEmvgL6LWCM3I42c",
        authDomain: "test-94545.firebaseapp.com",
        projectId: "test-94545",
        storageBucket: "test-94545.appspot.com",
        messagingSenderId: "286781232548",
        appId: "1:286781232548:android:4d96b879a5e4010dc45d31"),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
