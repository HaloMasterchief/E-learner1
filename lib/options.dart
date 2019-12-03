import 'books.dart';
import 'package:flutter/material.dart';
import 'videos.dart';
import 'package:e_learner/services/authentication.dart';
import 'admin.dart';
import 'package:firebase_database/firebase_database.dart';

final dbRef = FirebaseDatabase.instance.reference();

class OptionScreen extends StatefulWidget {
    OptionScreen({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  OptionScreenState createState() {
    return new OptionScreenState();
  }
}

class OptionScreenState extends State<OptionScreen> {

  bool _isButtonDisabled = true;
  Map <dynamic, dynamic> values;

  @override
  void initState() {
    checkAdmin();
    super.initState();
  }

  void checkAdmin(){
    var data = dbRef.child("Admins");
    data.once().then((DataSnapshot snapshot) {
      values = snapshot.value;

      setState(() {
        for(var k in values.keys)
          if(k.toString() == widget.auth.toString() || k.toString() == widget.userId)
            _isButtonDisabled = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.ondemand_video)),
                Tab(icon: Icon(Icons.book)),
              ],
            ),
            title: Text('E_Learner IIIT-Lucknow'),
            flexibleSpace: Container(
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: [
                      const Color(0xFF3366FF),
                      const Color(0xFF00CCFF),
                    ],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.person),
                tooltip: 'Admin',
                onPressed: _isButtonDisabled ? null : () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new AdminScreen()),
                  );
                },
              ),
              new FlatButton(
                child: new Text('Logout',
                style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: signOut)
            ],
          ),
          body: TabBarView(
            children: [
              videoSearch(),
              bookSearch(),
            ],
          ),
        ),
      ),
    );
  }

    signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

}