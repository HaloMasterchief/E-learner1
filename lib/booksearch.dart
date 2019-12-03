import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'dart:io';
import 'dart:convert';
import 'package:esys_flutter_share/esys_flutter_share.dart';

final dbRef = FirebaseDatabase.instance.reference();
final StorageReference storageRef = FirebaseStorage.instance.ref().child('Books');

class BookSearchScreen extends StatefulWidget{
  final String categorySelected;
  BookSearchScreen({Key key, this.categorySelected}) : super(key: key);

  BookSearchScreenState createState(){
    return new BookSearchScreenState();
  }
}

class BookSearchScreenState extends State<BookSearchScreen> {

  TextEditingController editingController = TextEditingController();

//  final duplicateItems = List<String>.generate(10000, (i) => "Item $i");
  var items = List<String>();
  var imgsrc;

  Map <dynamic, dynamic> values;

  @override
  void initState() {
    myFunc();
//    items.addAll(duplicateItems);
    super.initState();
  }

  myFunc() {
    var data = dbRef.child("Books").child(widget.categorySelected.toString());
    print("Data is " + data.toString());
    data.once().then((DataSnapshot snapshot) {
      values = snapshot.value;

      setState(() {
        items.clear();
        for (var k in values.keys){
          if((values[k])['App'] == 'Y')
            items.add(k.toString());
        }
      });
    });

  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = List<String>();
//    dummySearchList.addAll(items);
    for (var k in values.keys)
      if((values[k])['App'] == 'Y')
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

  void _settingModalBottomSheet(item) async {
    // display image in modal
    imgsrc = null;
    await loadImage(item);


    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: 240,
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
                    downloadPdf(storageRef.child(widget.categorySelected).child(
                        item + ".pdf"), item);
                    print('Download button clicked');
                  },
                ),
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
      imgRef = storageRef.child(widget.categorySelected).child(item + ".jpg");
      imgsrc2 = await imgRef.getDownloadURL();
    }
    catch (e) {
      imgRef = storageRef.child(widget.categorySelected).child(item + ".png");
      imgsrc2 = await imgRef.getDownloadURL();
    }

    print(imgsrc);
    setState(() {
      imgsrc = imgsrc2;
    });
    print(imgsrc);
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
//  Future<File> _downloadFile(String url, String filename) async {
//    var httpClient = new HttpClient();
//    var request = await httpClient.getUrl(Uri.parse(url));
//    var response = await request.close();
//    var bytes = await consolidateHttpClientResponseBytes(response);
//    String dir = (await getApplicationDocumentsDirectory()).path;
//    File file = new File('$dir/$filename');
//    await file.writeAsBytes(bytes);
//    print("Downloaded");
//    return file;
//  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Search for book"),
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
      ),
      body: Container(
        child: Column(
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.all(8.0),
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
                        borderRadius: BorderRadius.all(
                            Radius.circular(25.0)))),
              ),
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
                    subtitle: Text("Something"),
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