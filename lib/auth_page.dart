import 'package:flutter/material.dart';
import 'package:e_learner/services/authentication.dart';
import 'package:e_learner/pages/root_page.dart';

// void main() {
//   runApp(new MyApp());
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Sign in with your account',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootPage(auth: new Auth()));
  }
}
