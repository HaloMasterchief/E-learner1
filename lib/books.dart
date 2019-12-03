import 'package:flutter/material.dart';
import 'booksearch.dart';
import 'uploadBook.dart';

final List<String> _listViewData = [
  "Mathematics","Novels"
];
GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
class bookSearch extends StatefulWidget {

  bookSearchState createState(){
    return new bookSearchState();
  }
}

class bookSearchState extends State<bookSearch> {
  Widget build(BuildContext) {
    return Column(
      children: <Widget>[
        Container(height: 5,),
        RaisedButton(
          animationDuration: Duration(milliseconds: 300),
          color: Colors.blue,
          padding: const EdgeInsets.all(15),
          child: Text('Upload',
              style: TextStyle(fontSize: 15, color: Colors.white)),
          onPressed: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new UploadScreen()),
            );
          },
        ),
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
                      builder: (context) => new BookSearchScreen(categorySelected: data)),
                ),
              );
            }).toList(),
          ),
          )
          ]
    );
  }
}

/*TextField(
  onChanged: (text) {
    print("Enter book title: $text");
  },
);

crossAxisCount: 4,
        children: new List<Widget>.generate(16, (index) {
          return new GridTile(
            child: new Card(
              color: Colors.blue.shade200,
              child: new Center(
                child: new Text('tile $index')
 */