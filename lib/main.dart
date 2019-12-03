import 'package:flutter/material.dart';
import 'package:e_learner/auth_page.dart';

void main() => runApp(MaterialApp(
//  debugShowCheckedModeBanner: false,
  home: HomePage(),
));

// Home Page
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
        title: 'E-Learner IIITL',
        home: new Scaffold(
            resizeToAvoidBottomPadding: false,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                      'images/IIITL_logo.png',
                      height: 200,
                      width: 200,
                  ),
                  Text(
                    '\n\nE - Learner IIITL',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Container(height: 100),
                  RaisedButton(
                    animationDuration: Duration(milliseconds: 300),
                    color: Colors.blue,
                    padding: const EdgeInsets.all(15),
                    child: Text('Proceed',
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new MyApp()),
                      );
                    },
                  ),
                  Container(height: 20),
                ],
              ),
            ),

            backgroundColor: Colors.blue[700]));

  }
}