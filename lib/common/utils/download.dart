import 'dart:io';
import 'dart:math';

import 'package:arcacon_downloader/common/utility/string_converter.dart';
import 'package:arcacon_downloader/common/utils/download_path.dart';
import 'package:arcacon_downloader/common/utils/notification.dart';
import 'package:arcacon_downloader/common/utils/show_toast.dart';
import 'package:arcacon_downloader/screen/first_page.dart';
import 'package:arcacon_downloader/task_notifier.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

bool pipReady = false;

Future<DownloadTask> singleStartDownload(
    WidgetRef ref, String myUrl, int? index, Function? onProgress) async {
  DownloadTask downloadTask = DownloadTask();

  if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt > 32) {
      var request = await Permission.photos.request();
      if (request.isDenied) {
        downloadTask.result = Result.noPermission;
        return downloadTask;
      }
    } else {
      var request = await Permission.storage.request();
      if (request.isDenied) {
        downloadTask.result = Result.noPermission;
        return downloadTask;
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
    downloadTask.result = Result.connectError;
    return downloadTask;
  }

  var document = parser.parse(response.body);
  dom.Element? title = document.querySelector(
      'body > div.root-container > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-head > div.title-row > div');

  var titleText = title!.outerHtml.split('\n')[1];

  if (titleText.contains('[email&nbsp;protected]')) {
    titleText = convertEncodedTitleForDownload(titleText);
  }

  titleText = convertHtmlEscapedString(titleText);
  titleText = titleText.trim();
  var invalidChar = RegExp(r'[/:*?"<>|]');
  if (invalidChar.hasMatch(titleText)) {
    titleText = titleText.replaceAll(invalidChar, '');
  }

  dom.Element? maker = document.querySelector(
      'body > div.root-container > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-head > div.info-row.clearfix > div.member-info');

  var makerText = maker!.outerHtml.split('\n')[1];
  if (makerText.contains('[email&nbsp;protected]')) {
    makerText = convertEncodedTitleForDownload(makerText);
  }

  makerText = convertHtmlEscapedString(makerText);
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
  var arcaconId = int.parse(Uri.parse(myUrl).path.split('/').last);

  if (nowRunning.containsKey(arcaconId)) {
    downloadTask.result = Result.alreadyRunning;
    return downloadTask;
  }

  int randomValue = Random.secure().nextInt(2147483647);
  while (nowRunning.containsValue(randomValue)) {
    randomValue = Random.secure().nextInt(2147483647);
  }

  nowRunning[arcaconId] = randomValue;
  // runningTasks[arcaconId] = downloadTask;
  ref.read(taskStateProvider.notifier).add(arcaconId, downloadTask);
  if (onProgress != null) {
    onProgress();
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

    if (downloadVideo && !pipReady) {
      debugPrint('-----imageio 설치-----');
      var processRes =
          await Process.run('python', ['-m', 'pip', 'install', 'imageio']);
      debugPrint(processRes.stdout);
      debugPrint(processRes.stderr);
      debugPrint(processRes.exitCode.toString());
      debugPrint('-----imageio 종료-----');

      if (processRes.exitCode != 0) {
        downloadTask.result = Result.pipError;
        return downloadTask;
      }

      debugPrint('-----imageio[ffmpeg] 설치-----');
      processRes = await Process.run(
          'python', ['-m', 'pip', 'install', 'imageio[ffmpeg]']);
      debugPrint(processRes.stdout);
      debugPrint(processRes.stderr);
      debugPrint(processRes.exitCode.toString());
      debugPrint('-----imageio[ffmpeg] 종료-----');

      if (processRes.exitCode != 0) {
        downloadTask.result = Result.pipError;
        return downloadTask;
      }

      debugPrint('-----ffmpeg-python 설치-----');
      processRes = await Process.run(
          'python', ['-m', 'pip', 'install', 'ffmpeg-python']);
      debugPrint(processRes.stdout);
      debugPrint(processRes.stderr);
      debugPrint(processRes.exitCode.toString());
      debugPrint('-----ffmpeg-python 종료-----');

      if (processRes.exitCode != 0) {
        downloadTask.result = Result.pipError;
        return downloadTask;
      }

      pipReady = true;
    }
  }

  if (index == null) {
    downloadTask.itemCount = arcacon.length;
  } else {
    downloadTask.itemCount = 1;
  }

  ref.read(taskStateProvider.notifier).add(arcaconId, downloadTask);

  if (onProgress != null) {
    onProgress();
  }

  if (Platform.isAndroid || Platform.isIOS) {
    await progressNotification(arcaconId, titleText, 0, 1);
  }
  var videoDir = '${directory}videos/';

  if (index == null) {
    for (int i = 0; i < arcacon.length; i++) {
      var con = arcacon[i];
      await downloadToPath(con, arcaconTrueUrl, i, arcacon, videoDir, directory,
          downloadTask, pyDirectory);

      count++;
      downloadTask.completeCount = count;
      ref.watch(taskStateProvider.notifier).add(arcaconId, downloadTask);

      if (onProgress != null) {
        onProgress();
      }

      if (Platform.isAndroid || Platform.isIOS) {
        await progressNotification(arcaconId, titleText, count, arcacon.length);
      }
    }
  } else {
    var con = arcacon[index];
    await downloadToPath(
      con,
      arcaconTrueUrl,
      index,
      arcacon,
      videoDir,
      directory,
      downloadTask,
      pyDirectory,
    );

    count++;
    downloadTask.completeCount = count;
    ref.read(taskStateProvider.notifier).add(arcaconId, downloadTask);

    if (onProgress != null) {
      onProgress();
    }

    if (Platform.isAndroid || Platform.isIOS) {
      await progressNotification(arcaconId, titleText, count, 1);
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
    await Future.delayed(const Duration(milliseconds: 500));
    await flutterLocalNotificationsPlugin.cancel(nowRunning[arcaconId]!);
    await showNotification(arcaconId, titleText);
  }

  downloadTask.completeCount = count;
  ref.read(taskStateProvider.notifier).add(arcaconId, downloadTask);

  nowRunning.remove(arcaconId);
  ref.read(taskStateProvider.notifier).remove(arcaconId);
  if (onProgress != null) {
    onProgress();
  }
  downloadTask.result = Result.success;
  return downloadTask;
}
