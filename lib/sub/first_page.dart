import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as html;

final _ffmpeg = FlutterFFmpeg();
int _errCount = 0;
String myUrl = '';

Future<String?> downloadFile(String url, String fileName, String dir) async {
  try {
    var downloadUrl = Uri.parse(url);
    var client = http.Client();
    http.Response response = await client.get(downloadUrl);
    Directory(dir).createSync(recursive: true);
    var file = File('$dir/$fileName');
    file.createSync(recursive: true);
    await file.writeAsBytes(response.bodyBytes);
    //return null;
  } catch (ex) {
    //print('오류: ' + ex.toString());
    _errCount++;
    //return null;
  }
}

Future<bool> _startDownload(String myUrl) async {
  var request1 = await Permission.manageExternalStorage.request();
  var request2 = await Permission.storage.request();

  if (request1.isDenied || request2.isDenied) {
    return false;
  }

  Fluttertoast.showToast(
      msg: "다운로드를 시작하겠습니다!",
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.black87);

  var url = Uri.parse(myUrl);
  var client = http.Client();
  http.Response response = await client.get(url);
  var document = html.parse(response.body);
  html.Element? title = document.querySelector(
      'body > div > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-head > div.title-row > div');
  var titleText = title!.innerHtml.split('\n')[1];

  titleText = titleText.trim();
  var notvalid = RegExp(r'[\/:*?"<>|]');
  if (notvalid.hasMatch(titleText)) {
    //print('사용불가능한 문자 있음');
    //var oldtitle = titleText;
    titleText = titleText.replaceAll(notvalid, '');
  }

  html.Element? links = document.querySelector(
      'body > div > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-body > div');
  var arcacon = links!.innerHtml.split('\n');
  arcacon.removeAt(0);
  int i = 0;
  while (true) {
    if (arcacon.length <= i) break;
    if (arcacon[i] == '<div class="emoticon-tags">') {
      break;
    } else if (arcacon[i] == '') {
      arcacon.removeAt(i);
    }
    if (arcacon.length <= i) break;
    arcacon[i] = arcacon[i].replaceAll('<img loading="lazy" src="', '');
    arcacon[i] = arcacon[i].replaceAll('"/>', '');
    arcacon[i] = arcacon[i].replaceAll('">', '');
    arcacon[i] = arcacon[i].replaceAll(
        '<video loading="lazy" autoplay="" loop="" muted="" playsinline="" src="',
        '');
    arcacon[i] = arcacon[i].replaceAll('</video>', '');
    arcacon[i] = arcacon[i].replaceAll(' ', '');
    arcacon[i] = 'https:' + arcacon[i];
    //print(i.toString() + ':' + arcacon[i]);

    var directory = '/storage/emulated/0/Download/' + titleText + '/';

    if (arcacon[i].endsWith('.png')) {
      var fileType = '.png';
      await downloadFile(
          arcacon[i],
          (i + 1)
                  .toString()
                  .padLeft(arcacon.length.toString().length, '0')
                  .toString() +
              fileType,
          directory);
    } else if (arcacon[i].endsWith('.jpeg')) {
      var fileType = '.jpeg';
      await downloadFile(
          arcacon[i],
          (i + 1)
                  .toString()
                  .padLeft(arcacon.length.toString().length, '0')
                  .toString() +
              fileType,
          directory);
    } else if (arcacon[i].endsWith('.jpg')) {
      var fileType = '.jpg';
      await downloadFile(
          arcacon[i],
          (i + 1)
                  .toString()
                  .padLeft(arcacon.length.toString().length, '0')
                  .toString() +
              fileType,
          directory);
    } else if (arcacon[i].endsWith('.gif')) {
      var fileType = '.gif';
      await downloadFile(
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

      await _ffmpeg.executeWithArguments([
        '-y',
        '-i',
        videoDir + fileName,
        '-ss',
        '0',
        '-r',
        '15',
        '-hide_banner',
        ''
            '-loglevel',
        'quiet',
        directory + convertedFileName
      ]);
    }
    i++;
  }
  return true;
}

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('아카콘 다운로더'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 20),
                      labelText: '아카콘 링크'),
                  onChanged: (text) {
                    myUrl = text;
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: const Color(0xff3D414D),
                onPressed: () async => {
                  _errCount = 0,
                  if (myUrl.isEmpty)
                    {
                      Fluttertoast.showToast(
                          msg: "주소를 입력해주세요!",
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_SHORT,
                          backgroundColor: Colors.redAccent[400])
                    }
                  else
                    {
                      if (await _startDownload(myUrl))
                        {
                          if (_errCount == 0)
                            {
                              Fluttertoast.showToast(
                                  msg: "다운로드가 완료되었어요\nDownloads 폴더를 확인해보세요!",
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT,
                                  backgroundColor: Colors.indigoAccent)
                            }
                          else
                            {
                              Fluttertoast.showToast(
                                  msg:
                                      "$_errCount개의 오류가 발생했지만... 다운로드 작업을 완료했어요\nDownloads 폴더를 확인해보세요!",
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT,
                                  backgroundColor: Colors.green)
                            }
                        }
                      else
                        {
                          Fluttertoast.showToast(
                              msg: "허용되지 않은 권한이 있어요...",
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                              backgroundColor: Colors.deepOrangeAccent)
                        },
                    }
                },
                tooltip: '다운로드 시작',
                child: const Icon(Icons.download),
              ),
            ]));
  }
}
