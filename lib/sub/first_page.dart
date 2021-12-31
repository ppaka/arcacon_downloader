import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as html;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_custom_tabs_platform_interface/flutter_custom_tabs_platform_interface.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
int _errCount = 0;
final _ffmpeg = FlutterFFmpeg();
Map<String, int> nowRunning = {};

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

enum Result { NoPermission, CannotConnect, Success, AlreadyRunning }

Future<Result> _startDownload(String myUrl) async {
  var request = await Permission.storage.request();
  if (request.isDenied) {
    return Result.NoPermission;
  }
  Uri url;
  var client = http.Client();

  http.Response response;
  try {
    url = Uri.parse(myUrl);
    response = await client.get(url);
  } catch (ex) {
    return Result.CannotConnect;
  }

  var document = html.parse(response.body);
  html.Element? title = document.querySelector(
      'body > div.root-container > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-head > div.title-row > div');

  var titleText = title!.innerHtml.split('\n')[1];

  for (int j = 0; j < titleText.length; j++) {
    if (titleText.contains('<a href="/cdn-cgi/l/email-protection"')) {
      var lastIndex =
          titleText.lastIndexOf('<a href="/cdn-cgi/l/email-protection"');
      var endIndex = titleText.lastIndexOf('</a>') + 4;
      var emailSource = titleText.substring(lastIndex, endIndex);

      var valueStartIndex = emailSource.lastIndexOf('data-cfemail="') + 14;
      var valueEndIndex =
          emailSource.lastIndexOf('">[email&nbsp;protected]</a>');

      var encodedString = emailSource.substring(valueStartIndex, valueEndIndex);
      var email = "",
          r = int.parse(encodedString.substring(0, 2), radix: 16),
          n = 0,
          enI = 0;
      for (n = 2; encodedString.length - n > 0; n += 2) {
        enI = int.parse(encodedString.substring(n, n + 2), radix: 16) ^ r;
        email += String.fromCharCode(enI);
      }

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

  if (nowRunning.containsKey(titleText)) {
    return Result.AlreadyRunning;
  }

  Fluttertoast.showToast(
      msg: "다운로드를 시작하겠습니다!",
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.black87);

  int randomValue = Random.secure().nextInt(2147483647);

  while (nowRunning.containsValue(randomValue)) {
    randomValue = Random.secure().nextInt(2147483647);
  }

  nowRunning[titleText] = randomValue;
  await _progressNotification(titleText, 0, 1);

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
        File(outputPalettePath).deleteSync(recursive: true);
      } catch (ex) {
        print("오류: 팔레트 파일을 제거할 수 없음\n$ex");
      }
    }
    i++;
    await _progressNotification(titleText, i, arcacon.length);
  }

  await _progressNotification(titleText, 1, 1);

  await Future.delayed(const Duration(milliseconds: 500));
  await flutterLocalNotificationsPlugin.cancel(nowRunning[titleText]!);
  await _showNotification(titleText);
  nowRunning.remove(titleText);
  return Result.Success;
}

Future<void> _progressNotification(
    String conTitle, int nowProgress, int maxProgress) async {
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('Task Notifications ID', 'Task Notifications',
          // channelDescription: '',
          // settings
          importance: Importance.low,
          priority: Priority.low,
          channelAction: AndroidNotificationChannelAction.createIfNotExists,
          onlyAlertOnce: false,
          enableVibration: false,
          channelShowBadge: false,
          icon: 'ic_stat_name',
          playSound: false,
          setAsGroupSummary: false,
          autoCancel: false,
          // progress
          showProgress: true,
          maxProgress: maxProgress,
          progress: nowProgress,
          ongoing: true);
  final NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(nowRunning[conTitle]!,
      '아카콘 다운로드 중...', conTitle, platformChannelSpecifics,
      payload: 'item x');
}

Future<void> _showNotification(String conTitle) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'Ended Task Notifications ID', 'Ended Task Notifications',
          // channelDescription: '',
          channelShowBadge: true,
          importance: Importance.high,
          priority: Priority.high,
          onlyAlertOnce: false,
          icon: 'ic_stat_name',
          setAsGroupSummary: false);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(nowRunning[conTitle]!.hashCode,
      '아카콘 다운로드 완료!', conTitle, platformChannelSpecifics,
      payload: 'item x');
}

void _launchURL(BuildContext context) async {
  try {
    await launch(
      'https://arca.live/e/?p=1',
      customTabsOption: CustomTabsOption(
        toolbarColor: Colors.grey[850],
        enableDefaultShare: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
        animation: CustomTabsSystemAnimation.fade(),
        // or user defined animation.
        // animation: const CustomTabsAnimation(
        //   startEnter: 'slide_up',
        //   startExit: 'android:anim/fade_out',
        //   endEnter: 'android:anim/fade_in',
        //   endExit: 'slide_down',
        // ),
        extraCustomTabs: const <String>[
          // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
          'org.mozilla.firefox',
          // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
          'com.microsoft.emmx',
        ],
      ),
      safariVCOption: SafariViewControllerOption(
        preferredBarTintColor: Colors.grey[850],
        preferredControlTintColor: Colors.white,
        barCollapsingEnabled: true,
        entersReaderIfAvailable: false,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
      ),
    );
  } catch (e) {
    // An exception is thrown if browser app is not installed on Android device.
    debugPrint(e.toString());
  }
}

class FirstPage extends StatelessWidget {
  FirstPage({Key? key}) : super(key: key);

  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Result result;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
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
                  keyboardType: TextInputType.url,
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    ClipboardData? data = await Clipboard.getData('text/plain');
                    if (data != null) {
                      if (data.text != null) {
                        textController.text = data.text!;
                      }
                    }
                  },
                  child: const Text('붙여넣기')),
            ],
          ),
        ),
        floatingActionButton: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onPressed: () async {
                  _launchURL(context);
                },
                tooltip: '웹에서 검색',
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                backgroundColor: Theme.of(context).colorScheme.primary,
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
                      result = await _startDownload(textController.text),
                      if (result == Result.Success)
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
                      else if (result == Result.CannotConnect)
                        {
                          Fluttertoast.showToast(
                              msg: "해당 주소로 이동할 수 없습니다...",
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                              backgroundColor: Colors.red)
                        }
                      else if (result == Result.NoPermission)
                        {
                          Fluttertoast.showToast(
                              msg: "허용되지 않은 권한이 있어요...",
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                              backgroundColor: Colors.deepOrangeAccent)
                        }
                      else if (result == Result.AlreadyRunning)
                        {
                          Fluttertoast.showToast(
                              msg: "이미 다운로드가 진행중인 아카콘입니다!",
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                              backgroundColor: Colors.red)
                        },
                    }
                },
                tooltip: '다운로드 시작',
                child: Icon(Icons.download,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ]));
  }
}
