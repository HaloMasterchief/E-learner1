import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class AdminScreen extends StatefulWidget {

  AdminScreenState createState(){
    return new AdminScreenState();
  }
}

class AdminScreenState extends State<AdminScreen> {
  final dbRef = FirebaseDatabase.instance.reference();
  final StorageReference storageRef = FirebaseStorage.instance.ref().child('Books');

  var items = List<String>();
  var imgsrc;
  String _category;

  Map <dynamic, dynamic> values;

  @override
  void initState() {
    myFunc();
//    items.addAll(duplicateItems);
    super.initState();
  }

  myFunc() {
    var data = dbRef.child("Books").child(_category.toString());
    print("Data is " + data.toString());
    data.once().then((DataSnapshot snapshot) {
      values = snapshot.value;

      setState(() {
        items.clear();
        for (var k in values.keys){
          if((values[k])['App'] == 'N')
            items.add(k.toString());
        }
      });
    });

  }

  dropDown() {
    return DropdownButton(
      hint: new Text('Select category.'),
      value: _category,
      items: <DropdownMenuItem>[
        new DropdownMenuItem(
          child: new Text('Novels'),
          value: "Novels",
        ),
        new DropdownMenuItem(
          child: new Text('Mathematics'),
          value: "Mathematics",
        ),
        new DropdownMenuItem(
          child: new Text('Scanned_Notes'),
          value: "ScannedNotes",
        ),
        new DropdownMenuItem(
          child: new Text('Any'),
          value: "any",
        ),
      ],
      onChanged: (value) => setState(() {
        _category = value;
        myFunc();
//        _pickType = value;
      }),
    );
  }

  void _settingModalBottomSheet(item) async {
    // display image in modal
    imgsrc = null;
    await loadImage(item);


    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: 300,
            child: new Column(
              children: <Widget>[
                Image.network(
                  imgsrc.toString(),
                  height: 130,
                  width: 130,
                ),
                Text(item),
                Text("Year: " + (values[item])['Year'].toString()),
                IconButton(
                  icon: Icon(Icons.file_download),
                  tooltip: 'Download PDF.',
                  onPressed: () {
                    downloadPdf(storageRef.child(_category).child(
                        item + ".pdf"), item);
                    print('Download button clicked');
                  },
                ),
                FlatButton(
                  child: new Text('Approve'),
                  onPressed: () {approve(dbRef.child("Books").child(_category).child(item));},
                )
              ],
            ),
          );
        }
    );
  }

  Future loadImage(item) async {
    StorageReference imgRef;
    var imgsrc2;
    try {
      imgRef = storageRef.child(_category).child(item + ".jpg");
      imgsrc2 = await imgRef.getDownloadURL();
    }
    catch (e) {
      imgRef = storageRef.child(_category).child(item + ".png");
      imgsrc2 = await imgRef.getDownloadURL();
    }

    print(imgsrc);
    setState(() {
      imgsrc = imgsrc2;
    });
    print(imgsrc);
  }

  void approve(updateRef) {
    updateRef.update({
      'App': 'Y',
    });
    myFunc();
  }

  Future<void> downloadPdf(StorageReference ref, String item) async {
    final String url = await ref.getDownloadURL();
    print("URL is ...." + url);
    final http.Response downloadData = await http.get(url);
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/tmp.pdf');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    final StorageFileDownloadTask task = ref.writeToFile(tempFile);
    final int byteCount = (await task.future).totalByteCount;
    var bodyBytes = downloadData.bodyBytes;
    final String name = await ref.getName();
    final String path = await ref.getPath();
    print(
      'Success!\nDownloaded $name \nUrl: $url'
          '\npath: $path \nBytes Count :: $byteCount',
    );

    await Share.file(item, item+'.pdf', bodyBytes.buffer.asUint8List(), 'application/pdf');
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Admin Panel"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            dropDown(),

            Padding(
              padding: const EdgeInsets.all(8.0),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.asset(
                      'images/bookicon.png',
                      height: 40,
                      width: 40,
                    ),
                    title: Text('${items[index]}'),
                    subtitle: Text("Click to see more."),
                    onTap: () {
                      _settingModalBottomSheet('${items[index]}');
                    },

                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}