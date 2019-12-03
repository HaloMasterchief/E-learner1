import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:video_player/video_player.dart';
import 'package:e_learner/uploadVideo.dart';
import 'package:e_learner/chewie_list_item.dart';

final dbRef = FirebaseDatabase.instance.reference();


class VideoSearchScreen extends StatefulWidget {
  final String categorySelected;
  VideoSearchScreen({Key key, this.categorySelected}) : super(key: key);

  VideoSearchScreenState createState() {
    return new VideoSearchScreenState();
  }
}

class VideoSearchScreenState extends State<VideoSearchScreen> {
  TextEditingController editingController = TextEditingController();

  var items = List<String>();

  Map<dynamic, dynamic> values;
  
  @override
  void initState() {
    myFunc();
//    items.addAll(duplicateItems);
    super.initState();
  }

  myFunc() {
    var data = dbRef.child("Videos").child(widget.categorySelected.toString());
    print("Data is " + data.toString());
    data.once().then((DataSnapshot snapshot) {
      values = snapshot.value;

      setState(() {
      items.clear();
      for (var k in values.keys)   items.add(k.toString());
    });
    });
  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = List<String>();
//    dummySearchList.addAll(items);
    for (var k in values.keys)
      dummySearchList.add(k.toString());
    if (query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {
        if ((item.toLowerCase()).contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        for (var k in values.keys)
          items.add(k.toString());
      });
    }
    
   
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Search for video"),
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
          new FlatButton(
            child: new Text('Upload',
            style: new TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new UploadScreen(widget.categorySelected)),
            );
          },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            // RaisedButton(
            //   child: Text("See suggestions"),
            //   onPressed: myFunc,
            // ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      Text('${items[index]}',
                      style: TextStyle(color: Colors.black, fontSize: 20,fontStyle: FontStyle.italic),),
                      //onTap: (){ _settingModalBottomSheet('${items[index]}');
                      ChewieListItem(
                        videoPlayerController: VideoPlayerController.network(
                         //"https://firebasestorage.googleapis.com/v0/b/maximal-relic-220420.appspot.com/o/Videos%2FMathematics%2Fbbb-360p.mp4?alt=media&token=82872377-4806-49e7-9585-d15936247003",
                         (values['${items[index]}'])['URL'].toString(),
                        ),
                        looping: true,
                      ),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
