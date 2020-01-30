import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:youtube_api/youtube_api.dart';
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
  YoutubeAPI ytApi = new YoutubeAPI(key);
  List<YT_API> ytResult = [];
  Widget _appBarTitle = new Text('YouMate Search & Download');
  int gridCount = 2;

  @override
  void initState() {
    super.initState();
    _filter = new TextEditingController();
    _getNames(_searchText);
    _filter.addListener(() async {
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
      setState(() async {
        await _getNames(_searchText);
      });
    });
  }

  @override
  void dispose() {
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
              colors: [Colors.white, Color(0xFF4E4E4E)],
              begin: Alignment(10.0, 10.0),
              end: Alignment(5.0, 5.0),
            ),
          ),
          child: Container(
              margin: const EdgeInsets.only(
                top: 16.0,
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              child: LiquidPullToRefresh(
                onRefresh: () async {
                  _getNames(_searchText);
                }, // refresh callback
                backgroundColor: Colors.white,
                color: Colors.transparent,
                showChildOpacityTransition: false,
                child: GridView.builder(
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCount),
                    itemCount: ytResult.length,
                    itemBuilder: (_, int index) =>
                        listCards(index)), // scroll view
              )),
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
      print(url);
    }
  }

  _getNames(_searchText) async {
    var list = await ytApi.search(_searchText, type: 'video');
    setState(() => ytResult = list);
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
      child: Container(
          height: 150,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image:
                      NetworkImage(ytResult[index].thumbnail['default']['url']),
                  fit: BoxFit.fill)),
          child: SizedBox()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
      borderOnForeground: true,
    );
  }
}
