import 'dart:io';
import 'dart:math';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:arcacon_downloader/utility/custom_tab.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:video_player_win/video_player_win_plugin.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './screen/base_page.dart';
import './theme/style.dart';

void main() async {
  if (!kIsWeb && Platform.isWindows) WindowsVideoPlayer.registerWith();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en', 'US'), Locale('ko', 'KR')],
    themeMode: ThemeMode.system,
    theme: mat3LightTheme(),
    darkTheme: mat3DarkTheme(),
    home: const ArcaconDownloader(),
  ));
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
      var currentVersion = pi.version;
      var webVersion = (jsonData['tag_name'] as String).split('-').first;

      var arrX = currentVersion.split('.');
      var arrY = webVersion.split('.');

      var length = max(arrX.length, arrY.length);
      var needUpdate = false;

      for (int i = 0; i < length; i++) {
        int x,y;
        try {
          x = int.parse(arrX[i]);
        } on IndexError {
          x = 0;
        }

        try {
          y = int.parse(arrY[i]);
        } on IndexError {
          y = 0;
        }

        if (x > y){
          // 앱 버전이 큼
          needUpdate = false;
        } else if (x < y){
          // 비교 버전이 큼
          needUpdate = true;
        } else{
          needUpdate = false;
        }
      }

      return needUpdate;
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
    showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('업데이트 발견'),
            content: const Text('새 업데이트가 있습니다!'),
            actions: <Widget>[
              TextButton(
                child: const Text('나중에'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('다운로드'),
                onPressed: () {
                  if (isGooglePlay) {
                    if (Platform.isAndroid) {
                      launchURLtoBrowser(context,
                          'https://play.google.com/store/apps/details?id=com.ppaka.ArcaconDownloader');
                    }
                  } else {
                    if (Platform.isAndroid) {
                      launchURLtoBrowser(context,
                          'https://github.com/ppaka/arcacon_downloader/releases/latest/download/app-release.apk');
                    } else if (Platform.isWindows) {
                      launchURLtoBrowser(context,
                          'https://github.com/ppaka/arcacon_downloader/releases/latest/download/Windows.zip');
                    } else {
                      launchURLtoBrowser(context,
                          'https://github.com/ppaka/arcacon_downloader/releases/latest/');
                    }
                  }
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
        themeMode: ThemeMode.system,
        theme: mat3LightTheme(),
        darkTheme: mat3DarkTheme(),
        // debugShowCheckedModeBanner: false,
        home: const BasePage(title: '아카콘 다운로더'),
      ),
    );
  }
}
