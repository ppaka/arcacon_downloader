import 'dart:io';
import 'package:arcacon_downloader/utility/custom_tab.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './screen/base_page.dart';
import './theme/style.dart';

void main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
      title: '아카콘 다운로더',
      theme: material3(),
      darkTheme: material3Dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const ArcaconDownloader()));
  if (Platform.isWindows) {
    setWindowTitle('아카콘 다운로더');
  }
}

Future<bool> checkUpdate() async {
  try {
    var response = await http.get(Uri.parse(
        'https://api.github.com/repos/ppaka/arcacon_downloader/releases/latest'));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      var pi = await PackageInfo.fromPlatform();

      var version = (jsonData['tag_name'] as String).split('-').first;
      if (pi.version != version) {
        return true;
      } else {
        return false;
      }
    } else {
      throw Exception('업데이트 확인 실패');
    }
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

class ArcaconDownloader extends StatefulWidget {
  const ArcaconDownloader({Key? key}) : super(key: key);

  @override
  State<ArcaconDownloader> createState() => _ArcaconDownloaderState();
}

class _ArcaconDownloaderState extends State<ArcaconDownloader> {
  void showUpdateDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Column(
              children: const <Widget>[
                Text('업데이트 발견'),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  '새 업데이트가 있습니다!',
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('무시'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('다운로드'),
                onPressed: () {
                  launchURLtoBrowser(context,
                      'https://github.com/ppaka/arcacon_downloader/releases/latest');
                },
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var hasUpdate = await checkUpdate();
      if (hasUpdate) showUpdateDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: '아카콘 다운로더',
        theme: material3(),
        darkTheme: material3Dark(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const BasePage(title: '아카콘 다운로더'),
      ),
    );
  }
}
