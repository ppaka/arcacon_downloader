import 'dart:io';
import 'dart:math';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_custom_tabs_platform_interface/flutter_custom_tabs_platform_interface.dart';
import 'package:dio/dio.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Map<String, int> nowRunning = {};

class DownloadTask {
  int errorCount = 0;
  late Result result;
}

Future<bool> downloadFile(String url, String fileName, String dir) async {
  try {
    Dio dio = Dio();
    await dio.download(url, dir + fileName, deleteOnError: false);
    dio.close();
    print(fileName + ' 파일 다운로드 완료');
    return true;
  } catch (ex) {
    print(fileName + ' 오류: ' + ex.toString());
    return false;
  }
}

enum Result { noPermission, connectError, success, alreadyRunning }

void cancelAllTasks() {
  FFmpegKit.cancel();
}

Future<DownloadTask> _startDownload(String myUrl) async {
  DownloadTask result = DownloadTask();
  var request = await Permission.storage.request();
  if (request.isDenied) {
    result.result = Result.noPermission;
    return result;
  }
  var client = http.Client();

  http.Response response;
  try {
    response = await client.get(Uri.parse(myUrl));
  } catch (ex) {
    result.result = Result.connectError;
    return result;
  }

  var document = parser.parse(response.body);
  dom.Element? title = document.querySelector(
      'body > div.root-container > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-head > div.title-row > div');

  var titleText = title!.outerHtml.split('\n')[1];

  if (titleText.contains('[email&nbsp;protected]')) {
    titleText = convertEncodedTitle(titleText);
  }

  titleText = titleText.trim();
  var invalidChar = RegExp(r'[\/:*?"<>|]');
  if (invalidChar.hasMatch(titleText)) {
    titleText = titleText.replaceAll(invalidChar, '');
  }

  dom.Element links = document.querySelector(
      'body > div > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-body > div')!;

  int totalCount = 0;

  links.getElementsByTagName('video').forEach((element) {
    /*var eachUrl = 'https:' + element.attributes['src'].toString();
    arcacon.add(eachUrl);*/
    totalCount++;
  });
  links.getElementsByTagName('img').forEach((element) {
    /*var eachUrl = 'https:' + element.attributes['src'].toString();
    arcacon.add(eachUrl);*/
    totalCount++;
  });

  List<String> arcacon = [];

  print(totalCount);

  for (var element in links.children) {
    if(element.toString().startsWith('<div')) {
      break;
    }
    arcacon.add('https:'+element.attributes['src'].toString());
  }

  int count = 0;

  if (nowRunning.containsKey(titleText)) {
    result.result = Result.alreadyRunning;
    return result;
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

  var directory = '/storage/emulated/0/Download/' + titleText + '/';
  var videoDir = directory + 'videos/';
  var outputPalettePath = '';

  for (var con in arcacon) {
    if (con.endsWith('.png')) {
      var fileType = '.png';

      var res = await downloadFile(
          con,
          (count + 1)
                  .toString()
                  .padLeft(arcacon.length.toString().length, '0')
                  .toString() +
              fileType,
          directory);
      if (res == false) result.errorCount++;
    } else if (con.endsWith('.jpeg')) {
      var fileType = '.jpeg';
      var res = await downloadFile(
          con,
          (count + 1)
                  .toString()
                  .padLeft(arcacon.length.toString().length, '0')
                  .toString() +
              fileType,
          directory);
      if (res == false) result.errorCount++;
    } else if (con.endsWith('.jpg')) {
      var fileType = '.jpg';
      var res = await downloadFile(
          con,
          (count + 1)
                  .toString()
                  .padLeft(arcacon.length.toString().length, '0')
                  .toString() +
              fileType,
          directory);
      if (res == false) result.errorCount++;
    } else if (con.endsWith('.gif')) {
      var fileType = '.gif';
      var res = await downloadFile(
          con,
          (count + 1)
                  .toString()
                  .padLeft(arcacon.length.toString().length, '0')
                  .toString() +
              fileType,
          directory);
      if (res == false) result.errorCount++;
    } else if (con.endsWith('.mp4')) {
      var fileType = '.mp4';
      var fileName = (count + 1)
          .toString()
          .padLeft(arcacon.length.toString().length, '0')
          .toString();
      var convertedFileName = (count + 1)
              .toString()
              .padLeft(arcacon.length.toString().length, '0')
              .toString() +
          '.gif';
      var res = await downloadFile(con, fileName + fileType, videoDir);
      if (res == false) result.errorCount++;
      outputPalettePath = videoDir + 'palette.png';

      var fps = "25";

      var l = await FFprobeKit.execute(
          "-v 0 -of compact=p=0 -select_streams 0 -show_entries stream=r_frame_rate '${videoDir + fileName + fileType}'");
      await l.getOutput().then((value) => {
            if (value != null)
              {
                value = value.replaceAll("r_frame_rate=", ""),
                print("프레임" + value),
                fps = value
              }
          });

      await FFmpegKit.executeWithArguments([
        '-y',
        '-i',
        videoDir + fileName + fileType,
        '-vf',
        'fps=$fps,scale=100:-1:flags=lanczos,palettegen',
        '-hide_banner',
        '-loglevel',
        'error',
        videoDir + 'palette.png'
      ]).then((session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          print(fileName +
              fileType +
              " 팔레트 추출 성공 " +
              returnCode!.getValue().toString());
        } else if (ReturnCode.isCancel(returnCode)) {
          print(fileName +
              fileType +
              " 팔레트 추출 취소 " +
              returnCode!.getValue().toString());
        } else {
          print(fileName +
              fileType +
              " 팔레트 추출 오류 " +
              returnCode!.getValue().toString());
        }
      });
      await FFmpegKit.executeWithArguments([
        '-y',
        '-i',
        videoDir + fileName + fileType,
        '-i',
        videoDir + 'palette.png',
        '-filter_complex',
        'fps=$fps,scale=100:-1:flags=lanczos[x];[x][1:v]paletteuse',
        '-hide_banner',
        '-loglevel',
        'error',
        directory + convertedFileName
      ]).then((session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          print(fileName +
              fileType +
              " gif 변환 성공 " +
              returnCode!.getValue().toString());
        } else if (ReturnCode.isCancel(returnCode)) {
          print(fileName +
              fileType +
              " gif 변환 취소 " +
              returnCode!.getValue().toString());
        } else {
          print(fileName +
              fileType +
              " gif 변환 오류 " +
              returnCode!.getValue().toString());
        }
      });
      try {
        File(outputPalettePath).deleteSync(recursive: false);
      } catch (ex) {
        print("오류: 팔레트 파일을 제거할 수 없음\n$ex");
      }
    }
    count++;
    await _progressNotification(titleText, count, arcacon.length);
  }

  try {
    Directory(videoDir).deleteSync(recursive: true);
  } catch (ex) {
    print("오류: 원본 영상 파일을 제거할 수 없음\n$ex");
  }

  await _progressNotification(titleText, 1, 1);

  await Future.delayed(const Duration(milliseconds: 500));
  await flutterLocalNotificationsPlugin.cancel(nowRunning[titleText]!);
  await _showNotification(titleText);
  nowRunning.remove(titleText);
  result.result = Result.success;
  return result;
}

String convertEncodedTitle(String titleText) {
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
  return titleText;
}

Future<void> _progressNotification(
    String conTitle, int nowProgress, int maxProgress) async {
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('Task Notifications ID', 'Task Notifications',
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
    DownloadTask result;
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
                      if (result.result == Result.success)
                        {
                          if (result.errorCount == 0)
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
                                      "${result.errorCount}개의 오류가 발생했지만... 다운로드 작업을 완료했어요\nDownloads 폴더를 확인해보세요!",
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT,
                                  backgroundColor: Colors.green)
                            }
                        }
                      else if (result.result == Result.connectError)
                        {
                          Fluttertoast.showToast(
                              msg: "해당 주소로 이동할 수 없습니다...",
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                              backgroundColor: Colors.red)
                        }
                      else if (result.result == Result.noPermission)
                        {
                          Fluttertoast.showToast(
                              msg: "허용되지 않은 권한이 있어요...",
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_SHORT,
                              backgroundColor: Colors.deepOrangeAccent)
                        }
                      else if (result.result == Result.alreadyRunning)
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
