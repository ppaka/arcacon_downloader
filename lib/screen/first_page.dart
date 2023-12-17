import 'package:arcacon_downloader/common/widget/download_floating_button.dart';
import 'package:arcacon_downloader/common/widget/open_floating_button.dart';
import 'package:arcacon_downloader/common/widget/search_floating_button.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Map<int, int> nowRunning = {};
// Map<int, DownloadTask> runningTasks = {};

class DownloadTask {
  int errorCount = 0;
  int itemCount = 0;
  int completeCount = 0;
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

class FirstPage extends StatefulWidget {
  const FirstPage({
    super.key,
    required this.parentRef,
  });

  final WidgetRef parentRef;

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
          const SearchFloatingActionButton(),
          const SizedBox(height: 8),
          OpenFloatingActionButton(
              textController: textController, parentRef: widget.parentRef),
          const SizedBox(height: 8),
          DownloadFloatingActionButton(textController: textController),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
