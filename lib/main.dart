import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_extractor/youtube_extractor.dart';
import 'package:path_provider/path_provider.dart';
import 'video_view.dart';
import 'config/config.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'YouMate Search & Download'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static String key = Config.youtube_api_key;
  String _searchText = "";
  List names = new List(); // names we get from API
  List filteredNames = new List(); // names filtered by search text
  Icon _searchIcon = new Icon(Icons.search);
  TextEditingController _filter;
  String videoUrl = '';
  List<YT_API> ytResult = [];
  YoutubeAPI ytApi;
  Widget _appBarTitle = new Text('YouMate Search & Download');
  ReceivePort _port = ReceivePort();
  var extractor = YouTubeExtractor();

  @override
  void initState() {
    super.initState();
    _filter = new TextEditingController();
    ytApi = new YoutubeAPI(key);
    _getNames();

    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
      _getNames();
    });

//    FlutterDownloader.initialize();
//    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
//    _port.listen((dynamic data) {
//      String id = data[0];
//      DownloadTaskStatus status = data[1];
//      int progress = data[2];
//      setState((){ });
//    });
//    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
//    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
//    send.send([id, status, progress]);
  }

  @override
  void dispose() {
    //IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: _appBarTitle,
          leading: new IconButton(
            icon: _searchIcon,
            onPressed: _searchPressed,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color(0xFF4E4E4E)],
              begin: Alignment(10.0, 10.0),
              end: Alignment(5.0, 5.0),
            ),
          ),
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: ytResult.length,
              itemBuilder: (_, int index) => listCards(index)),
        ));
  }

  _watchVideo(url) {
    print("Matched youtube url: ${url}");
    if (url != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideoView(videoUrl: url)),
      );
    }
  }

  _downloadVideo(url) async {
    print("Download youtube url: ${url}");
    if (url != null) {
      var musicVideoInfo = await extractor.getMediaStreamsAsync(url);
      var urlVideo = musicVideoInfo.video.first.url;
      print(urlVideo);
//      final taskId = await FlutterDownloader.enqueue(
//        url: urlVideo,
//        savedDir: StorageDirectory.downloads.toString(),
//        showNotification: true, // show download progress in status bar (for Android)
//        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
//      );
//      final tasks = await FlutterDownloader.loadTasks();
    }
  }

  _getNames() async {
    ytResult = await ytApi.search(_searchText, type: 'video');
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('YouMate Search & Download');
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  Widget listCards(index) {
    return new Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: new Container(
        child: new Row(
          children: <Widget>[
            new Image.network(ytResult[index].thumbnail['default']['url'],
                fit: BoxFit.fill),
            new Padding(padding: EdgeInsets.only(right: 20.0)),
            new Expanded(
                child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new GestureDetector(
                    child: Text(ytResult[index].title,
                        softWrap: true,
                        style: TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.left
                    ),
                    onTap: () {
                      _watchVideo(ytResult[index].id);
                    },
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 1.5)),
                  Text(
                    ytResult[index].channelTitle,
                    softWrap: true,
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 3.0)),
                  Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Text(""),
                      ),
                      new Container(
                          margin: EdgeInsets.only(right: 5.0),
                          width: 30.0,
                          height: 30.0,
                          child: Align(
                            alignment: AlignmentDirectional.bottomEnd,
                            heightFactor: 0.0,
                            child: FloatingActionButton(
                              onPressed: () {
                                _downloadVideo(ytResult[index].id);
                              },
                              child: Icon(
                                Icons.file_download,
                                size: 15.0,
                              ),
                            ),
                          ))
                    ],
                  ),
                ]))
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
      borderOnForeground: true,
    );
  }
}
