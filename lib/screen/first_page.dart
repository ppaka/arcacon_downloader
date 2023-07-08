import 'dart:io';
import 'dart:math';
import 'package:arcacon_downloader/screen/base_page.dart';
import 'package:arcacon_downloader/utility/string_converter.dart';
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
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../utility/custom_tab.dart';

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
    // debugPrint('$fileName 파일 다운로드 완료');
    return true;
  } catch (ex) {
    debugPrint('$fileName 오류: $ex');
    return false;
  }
}

enum Result { noPermission, connectError, success, alreadyRunning, pipError }

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

  var request2 = await Permission.notification.request();
  if (request2.isDenied) {
    print('알림 권한 없음');
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
    titleText = convertEncodedTitleForDownload(titleText);
  }

  titleText = titleText.trim();
  var invalidChar = RegExp(r'[\/:*?"<>|]');
  if (invalidChar.hasMatch(titleText)) {
    titleText = titleText.replaceAll(invalidChar, '');
  }

  dom.Element links = document.querySelector(
      'body > div > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-body > div')!;

  int totalCount = 0;
  bool downloadVideo = false;

  links.getElementsByTagName('video').forEach((element) {
    /*var eachUrl = 'https:' + element.attributes['src'].toString();
    arcacon.add(eachUrl);*/
    totalCount++;
    downloadVideo = true;
  });
  links.getElementsByTagName('img').forEach((element) {
    /*var eachUrl = 'https:' + element.attributes['src'].toString();
    arcacon.add(eachUrl);*/
    totalCount++;
  });

  List<String> arcacon = [];
  List<String> arcaconTrueUrl = [];

  debugPrint('Total: $totalCount');

  for (var element in links.children) {
    if (element.toString().startsWith('<div')) {
      break;
    }

    if (element.attributes['data-src'].toString() != "null") {
      var uri = 'https:${element.attributes['data-src']}';
      var convertedUri = uri.replaceRange(uri.indexOf('?'), uri.length, '');
      arcacon.add(convertedUri);
      arcaconTrueUrl.add(uri);
      continue;
    }
    if (element.attributes['src'].toString() != "null") {
      var uri = 'https:${element.attributes['src']}';
      var convertedUri = uri.replaceRange(uri.indexOf('?'), uri.length, '');
      arcacon.add(convertedUri);
      arcaconTrueUrl.add(uri);
      continue;
    }
  }

  int count = 0;

  if (nowRunning.containsKey(titleText)) {
    result.result = Result.alreadyRunning;
    return result;
  }

  if (Platform.isAndroid || Platform.isIOS) {
    Fluttertoast.showToast(
      msg: "다운로드를 시작하겠습니다!",
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  } else {
    showToast(
      Colors.black87,
      Icons.download_rounded,
      "다운로드를 시작하겠습니다!",
      Colors.white,
      null,
    );
  }

  int randomValue = Random.secure().nextInt(2147483647);
  while (nowRunning.containsValue(randomValue)) {
    randomValue = Random.secure().nextInt(2147483647);
  }

  nowRunning[titleText] = randomValue;
  if (Platform.isAndroid || Platform.isIOS) {
    await _progressNotification(titleText, 0, 1);
  }

  var directory = '';
  var pyDirectory = '';
  if (Platform.isAndroid) {
    directory = '/storage/emulated/0/Download/$titleText/';
  } else if (Platform.isIOS) {
    directory = '';
  } else {
    directory =
        '${(await getDownloadsDirectory() as Directory).path}/$titleText/';
    // debugPrint("---- $directory ----");

    var exePath = Platform.resolvedExecutable.toString();
    var exeDirectory =
        exePath.replaceRange(exePath.lastIndexOf('\\') + 1, null, '');
    pyDirectory = '$exeDirectory\\res\\';

    if (downloadVideo) {
      debugPrint('-----imageio 설치-----');
      var processRes =
          await Process.run('python', ['-m', 'pip', 'install', 'imageio']);
      debugPrint(processRes.stdout);
      debugPrint(processRes.stderr);
      debugPrint(processRes.exitCode.toString());
      debugPrint('-----imageio 종료-----');

      if (processRes.exitCode != 0) {
        result.result = Result.pipError;
        return result;
      }

      debugPrint('-----imageio[ffmpeg] 설치-----');
      processRes = await Process.run(
          'python', ['-m', 'pip', 'install', 'imageio[ffmpeg]']);
      debugPrint(processRes.stdout);
      debugPrint(processRes.stderr);
      debugPrint(processRes.exitCode.toString());
      debugPrint('-----imageio[ffmpeg] 종료-----');

      if (processRes.exitCode != 0) {
        result.result = Result.pipError;
        return result;
      }

      debugPrint('-----ffmpeg-python 설치-----');
      processRes = await Process.run(
          'python', ['-m', 'pip', 'install', 'ffmpeg-python']);
      debugPrint(processRes.stdout);
      debugPrint(processRes.stderr);
      debugPrint(processRes.exitCode.toString());
      debugPrint('-----ffmpeg-python 종료-----');

      if (processRes.exitCode != 0) {
        result.result = Result.pipError;
        return result;
      }
    }
  }

  var videoDir = '${directory}videos/';

  for (int i = 0; i < arcacon.length; i++) {
    var con = arcacon[i];
    if (con.endsWith('.png')) {
      var fileType = '.png';

      var res = await downloadFile(
          arcaconTrueUrl[i],
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
          arcaconTrueUrl[i],
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
          arcaconTrueUrl[i],
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
          arcaconTrueUrl[i],
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
      var convertedFileName =
          '${(count + 1).toString().padLeft(arcacon.length.toString().length, '0')}.gif';
      var res =
          await downloadFile(arcaconTrueUrl[i], fileName + fileType, videoDir);
      if (res == false) result.errorCount++;
      var outputPalettePath = '${videoDir}palette.png';

      if (Platform.isAndroid || Platform.isIOS) {
        var fps = 25.0;

        var l = await FFprobeKit.execute(
            "-v 0 -of compact=p=0 -select_streams 0 -show_entries stream=r_frame_rate '${videoDir + fileName + fileType}'");
        await l.getOutput().then((value) => {
              if (value != null)
                {
                  value = value.replaceAll("r_frame_rate=", ""),
                  fps = double.parse(value.split('/')[0]) /
                      double.parse(value.split('/')[1]),
                  debugPrint("프레임: $value ($fps)"),
                }
            });

        while (fps > 50) {
          fps = fps / 2;
          debugPrint("프레임 변경: $fps");
        }

        await FFmpegKit.executeWithArguments([
          '-y',
          '-i',
          videoDir + fileName + fileType,
          '-vf',
          'scale=100:-1:flags=lanczos,palettegen',
          '-hide_banner',
          '-loglevel',
          'error',
          '${videoDir}palette.png'
        ]).then((session) async {
          final returnCode = await session.getReturnCode();

          if (ReturnCode.isSuccess(returnCode)) {
            debugPrint(
                "$fileName$fileType 팔레트 추출 성공 ${returnCode!.getValue()}");
          } else if (ReturnCode.isCancel(returnCode)) {
            debugPrint(
                "$fileName$fileType 팔레트 추출 취소 ${returnCode!.getValue()}");
          } else {
            debugPrint(
                "$fileName$fileType 팔레트 추출 오류 ${returnCode!.getValue()}");
          }
        });
        await FFmpegKit.executeWithArguments([
          '-y',
          '-i',
          videoDir + fileName + fileType,
          '-i',
          '${videoDir}palette.png',
          '-filter_complex',
          'scale=100:-1:flags=lanczos[x];[x][1:v]paletteuse',
          '-hide_banner',
          '-loglevel',
          'error',
          '-r',
          fps.toString(),
          directory + convertedFileName
        ]).then((session) async {
          final returnCode = await session.getReturnCode();

          if (ReturnCode.isSuccess(returnCode)) {
            debugPrint(
                "$fileName$fileType gif 변환 성공 ${returnCode!.getValue()}");
          } else if (ReturnCode.isCancel(returnCode)) {
            debugPrint(
                "$fileName$fileType gif 변환 취소 ${returnCode!.getValue()}");
          } else {
            debugPrint(
                "$fileName$fileType gif 변환 오류 ${returnCode!.getValue()}");
            result.errorCount++;
          }
        });
      } else {
        var processRes = await Process.run('python', [
          '${pyDirectory}convert.py',
          videoDir + fileName + fileType,
          directory + convertedFileName,
          outputPalettePath
        ]);
        debugPrint(processRes.stdout.toString());
        debugPrint(processRes.stderr.toString());
        debugPrint(processRes.exitCode.toString());
      }

      if (await File(outputPalettePath).exists()) {
        try {
          await File(outputPalettePath).delete(recursive: false);
        } catch (ex) {
          debugPrint("오류: 팔레트 파일을 제거할 수 없음\n$ex");
        }
      }
    }
    count++;
    if (Platform.isAndroid || Platform.isIOS) {
      await _progressNotification(titleText, count, arcacon.length);
    }
  }

  if (await Directory(videoDir).exists()) {
    try {
      await Directory(videoDir).delete(recursive: true);
    } catch (ex) {
      debugPrint("오류: 원본 영상 파일을 제거할 수 없음\n$ex");
    }
  }

  if (Platform.isAndroid || Platform.isIOS) {
    await _progressNotification(titleText, 1, 1);

    await Future.delayed(const Duration(milliseconds: 500));
    await flutterLocalNotificationsPlugin.cancel(nowRunning[titleText]!);
    await _showNotification(titleText);
  }

  nowRunning.remove(titleText);
  result.result = Result.success;
  return result;
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

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                      labelText: '아카콘 링크',
                    ),
                    controller: textController,
                    keyboardType: TextInputType.url),
              ),
              const SizedBox(width: 0, height: 8),
              ElevatedButton(
                  onPressed: () async {
                    ClipboardData? data = await Clipboard.getData('text/plain');
                    if (data != null) {
                      if (data.text != null) {
                        textController.text = data.text as String;
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
                onPressed: () async {
                  if (Platform.isAndroid || Platform.isIOS) {
                    launchURL(context, 'https://arca.live/e/?p=1');
                  } else {
                    launchURLtoBrowser(context, 'https://arca.live/e/?p=1');
                  }
                },
                mini: true,
                heroTag: UniqueKey().toString(),
                child: const Icon(Icons.search),
              ),
              const SizedBox(
                height: 8,
              ),
              FloatingActionButton(
                onPressed: () async {
                  if (textController.text.isEmpty) {
                    if (Platform.isAndroid || Platform.isIOS) {
                      Fluttertoast.showToast(
                        msg: "주소를 입력해주세요!",
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_SHORT,
                        backgroundColor: Colors.redAccent[400],
                        textColor: Colors.white,
                      );
                    } else {
                      showToast(
                        Colors.redAccent,
                        Icons.warning_rounded,
                        "주소를 입력해주세요!",
                        Colors.white,
                        null,
                      );
                    }
                  } else {
                    onPressStartDownload(textController.text);
                  }
                },
                mini: true,
                heroTag: UniqueKey().toString(),
                child: const Icon(Icons.download),
              ),
            ]));
  }

  @override
  bool get wantKeepAlive => true;
}

Future<void> onPressStartDownload(String url) async {
  var result = await _startDownload(url);
  if (result.result == Result.success) {
    if (result.errorCount == 0) {
      if (Platform.isAndroid || Platform.isIOS) {
        Fluttertoast.showToast(
          msg: "다운로드가 완료되었어요\nDownload 폴더를 확인해보세요!",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.indigoAccent,
          textColor: Colors.white,
        );
      } else {
        showToast(
          Colors.indigoAccent,
          Icons.check_rounded,
          "다운로드가 완료되었어요\nDownload 폴더를 확인해보세요!",
          Colors.white,
          null,
        );
      }
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        Fluttertoast.showToast(
          msg:
              "${result.errorCount}개의 오류가 발생했지만... 다운로드 작업을 완료했어요\nDownloads 폴더를 확인해보세요!",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        showToast(
          Colors.green,
          Icons.check_rounded,
          "${result.errorCount}개의 오류가 발생했지만... 다운로드 작업을 완료했어요\nDownloads 폴더를 확인해보세요!",
          Colors.white,
          null,
        );
      }
    }
  } else if (result.result == Result.connectError) {
    if (Platform.isAndroid || Platform.isIOS) {
      Fluttertoast.showToast(
        msg: "해당 주소로 이동할 수 없습니다...",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      showToast(
        Colors.red,
        Icons.error_rounded,
        "해당 주소로 이동할 수 없습니다...",
        Colors.white,
        null,
      );
    }
  } else if (result.result == Result.noPermission) {
    if (Platform.isAndroid || Platform.isIOS) {
      Fluttertoast.showToast(
          msg: "허용되지 않은 권한이 있어요...",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.deepOrangeAccent,
          textColor: Colors.white);
    } else {
      showToast(
        Colors.deepOrangeAccent,
        Icons.warning_rounded,
        "허용되지 않은 권한이 있어요...",
        Colors.white,
        null,
      );
    }
  } else if (result.result == Result.alreadyRunning) {
    if (Platform.isAndroid || Platform.isIOS) {
      Fluttertoast.showToast(
        msg: "이미 다운로드가 진행중인 아카콘입니다!",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      showToast(
        Colors.red,
        Icons.notifications_rounded,
        "이미 다운로드가 진행중인 아카콘입니다!",
        Colors.white,
        null,
      );
    }
  } else if (result.result == Result.pipError) {
    if (Platform.isAndroid || Platform.isIOS) {
      Fluttertoast.showToast(
        msg: "파이썬 pip 모듈을 설치하는데 오류가 발생했습니다...",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      showToast(
        Colors.red,
        Icons.error_outline_rounded,
        "파이썬 pip 모듈을 설치하는데 오류가 발생했습니다...",
        Colors.white,
        null,
      );
    }
  }
}
