import 'package:flutter/material.dart';
import 'videosearch.dart';

final List<String> _listViewData = [
  "Computer Science","Mathematics","Physics"
];

class videoSearch extends StatefulWidget {
  videoSearchState createState() {
    return new videoSearchState();
  }
}

class videoSearchState extends State<videoSearch> {
  Widget build(BuildContext) {
    
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.all(20.0),
            child: Text(
              'Search by category',
              style: TextStyle(color: Colors.black, fontSize: 20,fontStyle: FontStyle.italic),
            ),
          ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(10.0),
            children: _listViewData.reversed.map((data) {
              return ListTile(
                title: Text(data),
                onTap: () => Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new VideoSearchScreen(categorySelected: data)),
                ),
              );
            }).toList(),
          ),
          )
          ]
    );
  }
}
