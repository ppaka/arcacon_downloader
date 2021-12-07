// @dart=2.9
import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // Contains a client for making API calls
import 'package:html/parser.dart'
    as html; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart'
    as html; // Contains DOM related classes for extracting data from elements

void main() {
  runApp(const MyApp());
}

final _ffmpeg = FlutterFFmpeg();

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '아카콘 다운로더',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '아카콘 다운로더'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<String> downloadFile(String url, String fileName, String dir) async {
  try {
    var downloadUrl = Uri.parse(url);
    var client = http.Client();
    http.Response response = await client.get(downloadUrl);
    print('응답: ' + fileName);
    var filePath = '$dir/$fileName';
    var file = File(filePath);
    file.createSync(recursive: true);
    await file.writeAsBytes(response.bodyBytes);
    return null;
  } catch (ex) {
    print('오류: ' + ex);
    return null;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _incrementCounter(String myUrl) async {
    var url = Uri.parse(myUrl);
    var client = http.Client();
    http.Response response = await client.get(url);
    var document = html.parse(response.body);
    html.Element title = document.querySelector(
        'body > div > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-head > div.title-row > div');
    var titleText = title.innerHtml.split('\n')[1];

    titleText = titleText.trim();
    var notvalid = RegExp(r'[\/:*?"<>|]');
    if (notvalid.hasMatch(titleText)) {
      print('사용불가능한 문자 있음');
      var oldtitle = titleText;
      titleText = titleText.replaceAll(notvalid, '');
    }

    html.Element links = document.querySelector(
        'body > div > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-body > div');
    var arcacon = links.innerHtml.split('\n');
    arcacon.removeAt(0);
    for (int i = 0; i < arcacon.length; i++) {
      if (arcacon[i] == '<div class="emoticon-tags">') {
        break;
      } else if (arcacon[i] == '') {
        arcacon.removeAt(i);
      }
      arcacon[i] = arcacon[i].replaceAll('<img loading="lazy" src="', '');
      arcacon[i] = arcacon[i].replaceAll('"/>', '');
      arcacon[i] = arcacon[i].replaceAll('">', '');
      arcacon[i] = arcacon[i].replaceAll(
          '<video loading="lazy" autoplay="" loop="" muted="" playsinline="" src="',
          '');
      arcacon[i] = arcacon[i].replaceAll('</video>', '');
      arcacon[i] = arcacon[i].replaceAll(' ', '');
      arcacon[i] = 'https:' + arcacon[i];
      print(i.toString() + ':' + arcacon[i]);

      var directory = '/sdcard/download/' + titleText + '/';

      if (arcacon[i].endsWith('.png')) {
        var fileType = '.png';
        downloadFile(
            arcacon[i],
            (i + 1)
                    .toString()
                    .padLeft(arcacon.length.toString().length, '0')
                    .toString() +
                fileType,
            directory);
      } else if (arcacon[i].endsWith('.jpeg')) {
        var fileType = '.jpeg';
        downloadFile(
            arcacon[i],
            (i + 1)
                    .toString()
                    .padLeft(arcacon.length.toString().length, '0')
                    .toString() +
                fileType,
            directory);
      } else if (arcacon[i].endsWith('.jpg')) {
        var fileType = '.jpg';
        downloadFile(
            arcacon[i],
            (i + 1)
                    .toString()
                    .padLeft(arcacon.length.toString().length, '0')
                    .toString() +
                fileType,
            directory);
      } else if (arcacon[i].endsWith('.gif')) {
        var fileType = '.gif';
        downloadFile(
            arcacon[i],
            (i + 1)
                    .toString()
                    .padLeft(arcacon.length.toString().length, '0')
                    .toString() +
                fileType,
            directory);
      } else if (arcacon[i].endsWith('.mp4')) {
        var fileType = '.mp4';
        var fileName = (i + 1)
                .toString()
                .padLeft(arcacon.length.toString().length, '0')
                .toString() +
            fileType;
        var videoDir = directory + 'videos/';
        var convertedFileName = (i + 1)
                .toString()
                .padLeft(arcacon.length.toString().length, '0')
                .toString() +
            '.gif';
        await downloadFile(arcacon[i], fileName, videoDir);

        //var convert = await _flutterVideoCompress.convertVideoToGif(videoDir+fileName);
        _ffmpeg.executeWithArguments([
          '-y',
          '-i',
          videoDir + fileName,
          '-ss',
          '0',
          '-r',
          '15',
          directory + convertedFileName
        ]);
        //print(convert.path);
      }
    }
    setState(() {
      //_flutterVideoCompress.convertVideoToGif('');
    });
  }

  static String myUrl;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TextField(
                decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 20),
                    labelText: '링크를 적어주세요'),
                onChanged: (text) {
                  myUrl = text;
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _incrementCounter(myUrl),
        tooltip: '다운로드 시작',
        child: const Icon(Icons.download),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
