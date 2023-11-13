import 'dart:io';
import 'dart:math';
import 'package:arcacon_downloader/common/utility/string_converter.dart';
import 'package:arcacon_downloader/common/utils/download_path.dart';
import 'package:arcacon_downloader/common/utils/show_toast.dart';
import 'package:arcacon_downloader/screen/first_page.dart';
import 'package:arcacon_downloader/task_item.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:arcacon_downloader/common/utils/notification.dart';

Future<DownloadTask> singleStartDownload(String myUrl, int? index) async {
  DownloadTask result = DownloadTask();

  if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt > 32) {
      var request = await Permission.photos.request();
      if (request.isDenied) {
        result.result = Result.noPermission;
        return result;
      }
    } else {
      var request = await Permission.storage.request();
      if (request.isDenied) {
        result.result = Result.noPermission;
        return result;
      }
    }
    var request2 = await Permission.notification.request();
    if (request2.isDenied) {
      print('알림 권한 없음');
    }
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

  dom.Element? maker = document.querySelector(
      'body > div.root-container > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-head > div.info-row.clearfix > div.member-info');

  var makerText = maker!.outerHtml.split('\n')[1];
  if (makerText.contains('[email&nbsp;protected]')) {
    makerText = convertEncodedTitleForDownload(makerText);
  }

  makerText = makerText.trim();

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
  var taskItem = TaskItem();
  taskItem.arcaconUrl = myUrl;
  taskItem.title = titleText;
  taskItem.maker = makerText;
  taskItem.progress = 0;

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
    await progressNotification(titleText, 0, 1);
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

  if (index == null) {
    for (int i = 0; i < arcacon.length; i++) {
      var con = arcacon[i];
      await downloadToPath(con, arcaconTrueUrl, i, arcacon, videoDir, directory,
          result, pyDirectory);
    }
  } else {
    var con = arcacon[index];
    await downloadToPath(con, arcaconTrueUrl, index, arcacon, videoDir,
        directory, result, pyDirectory);
  }

  count++;
  if (Platform.isAndroid || Platform.isIOS) {
    await progressNotification(titleText, count, 1);
  }

  if (await Directory(videoDir).exists()) {
    try {
      await Directory(videoDir).delete(recursive: true);
    } catch (ex) {
      debugPrint("오류: 원본 영상 파일을 제거할 수 없음\n$ex");
    }
  }

  if (Platform.isAndroid || Platform.isIOS) {
    await Future.delayed(const Duration(milliseconds: 500));
    await flutterLocalNotificationsPlugin.cancel(nowRunning[titleText]!);
    await showNotification(titleText);
  }

  nowRunning.remove(titleText);
  result.result = Result.success;
  return result;
}