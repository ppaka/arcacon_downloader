import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as html;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

int _errCount = 0;
final _ffmpeg = FlutterFFmpeg();

Future<void> downloadFile(String url, String fileName, String dir) async {
  try {
    Directory(dir).createSync(recursive: true);
    var downloadUrl = Uri.parse(url);
    var client = http.Client();
    http.Response response = await client.get(downloadUrl);
    var file = File('$dir$fileName');
    file.createSync(recursive: true);
    await file.writeAsBytes(response.bodyBytes);
    print('파일 다운로드 완료');
    //sleep(const Duration(seconds: 2));
  } catch (ex) {
    print('오류: ' + ex.toString());
    _errCount++;
  }
}

Future<bool> _startDownload(String myUrl) async {
  // var request1 = await Permission.manageExternalStorage.request();
  // await FlutterDownloader.initialize(debug: true);
  var request2 = await Permission.storage.request();

  //if (request1.isDenied || request2.isDenied) {
  if (request2.isDenied) {
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
      'body > div.root-container > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-head > div.title-row > div');

  //print(title!.innerHtml);
  //print(title.innerHtml.split('\n')[1]);

  var titleText = title!.innerHtml.split('\n')[1];

  for (int j = 0; j < titleText.length; j++) {
    if (titleText.contains('<a href="/cdn-cgi/l/email-protection"')) {
      var lastIndex =
          titleText.lastIndexOf('<a href="/cdn-cgi/l/email-protection"');
      var endIndex = titleText.lastIndexOf('</a>') + 4;
      //print(lastIndex);
      //print(endIndex);

      var emailSource = titleText.substring(lastIndex, endIndex);
      //print(emailSource);

      var valueStartIndex = emailSource.lastIndexOf('data-cfemail="') + 14;
      //print(valueStartIndex);
      var valueEndIndex =
          emailSource.lastIndexOf('">[email&nbsp;protected]</a>');
      //print(valueEndIndex);

      var encodedString = emailSource.substring(valueStartIndex, valueEndIndex);
      //print(encodedString);
      var email = "",
          r = int.parse(encodedString.substring(0, 2), radix: 16),
          n = 0,
          enI = 0;
      for (n = 2; encodedString.length - n > 0; n += 2) {
        enI = int.parse(encodedString.substring(n, n + 2), radix: 16) ^ r;
        email += String.fromCharCode(enI);
      }
      //print(email);

      titleText = titleText.substring(0, lastIndex) +
          email +
          titleText.substring(endIndex);
    }
  }

  titleText = titleText.trim();
  var invalidChar = RegExp(r'[\/:*?"<>|]');
  if (invalidChar.hasMatch(titleText)) {
    //var oldTitle = titleText;
    titleText = titleText.replaceAll(invalidChar, '');
  }

  html.Element? links = document.querySelector(
      'body > div > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-body > div');
  var arcacon = links!.innerHtml.split('\n');
  arcacon.removeAt(0);
  int i = 0;
  String outputPalettePath = '';
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

    var directory = '/storage/emulated/0/Download/' + titleText + '/';

    /// Get Android [downloads] top-level shared folder
    /// You can also create a reference to a custom directory as: `EnvironmentDirectory.custom('Custom Folder')`
    // final sharedDirectory = await getExternalStoragePublicDirectory(EnvironmentDirectory.custom('Download/' + titleText + '/'));

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
          .toString();
      var videoDir = directory + 'videos/';
      var convertedFileName = (i + 1)
              .toString()
              .padLeft(arcacon.length.toString().length, '0')
              .toString() +
          '.gif';
      await downloadFile(arcacon[i], fileName + fileType, videoDir);
      //String inputPath = videoDir + fileName + fileType;
      outputPalettePath = videoDir + 'palette.png';
      await _ffmpeg.executeWithArguments([
        '-y',
        '-i',
        videoDir + fileName + fileType,
        '-vf',
        'fps=24,scale=100:-1:flags=lanczos,palettegen',
        '-hide_banner',
        '-loglevel',
        'error',
        videoDir + 'palette.png'
      ]);
      //String outputPath = directory + convertedFileName;
      await _ffmpeg.executeWithArguments([
        '-y',
        '-i',
        videoDir + fileName + fileType,
        '-i',
        videoDir + 'palette.png',
        '-filter_complex',
        'fps=24,scale=100:-1:flags=lanczos[x];[x][1:v]paletteuse',
        '-hide_banner',
        '-loglevel',
        'error',
        directory + convertedFileName
      ]);
      try {
        //print('팔레트 파일 제거: $outputPalettePath');
        File(outputPalettePath).deleteSync(recursive: true);
        //File(videoDir + 'palette.png').deleteSync(recursive: true);
      } catch (ex) {
        print("오류: 팔레트 파일을 제거할 수 없음\n$ex");

        //print('팔레트 생성');
      }
    }
    i++;
  }
  return true;
}

class FirstPage extends StatelessWidget {
  FirstPage({Key? key}) : super(key: key);

  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('아카콘 다운로더'),
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
                  controller: textController,
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    ClipboardData? data = await Clipboard.getData('text/plain');
                    if (data!.text != null) {
                      textController.text = data.text!;
                    }
                  },
                  child: const Text('붙여넣기'))
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
                  if (textController.text.isEmpty)
                    {
                      Fluttertoast.showToast(
                          msg: "주소를 입력해주세요!",
                          gravity: ToastGravity.BOTTOM,
                          toastLength: Toast.LENGTH_SHORT,
                          backgroundColor: Colors.redAccent[400])
                    }
                  else
                    {
                      if (await _startDownload(textController.text))
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
