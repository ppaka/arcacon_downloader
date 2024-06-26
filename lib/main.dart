import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:arcacon_downloader/common/theme/style.dart';
import 'package:arcacon_downloader/common/utility/custom_tab.dart';
import 'package:arcacon_downloader/screen/base_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:window_size/window_size.dart';

import 'common/utils/download.dart';

void main() async {
  if (!kIsWeb && Platform.isWindows) {
    // WindowsVideoPlayer.registerWith();
    initPythonScript();
  }
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  WidgetsFlutterBinding.ensureInitialized();

  MediaKit.ensureInitialized();

  if (isGooglePlay) {
    runApp(
      ProviderScope(
        child: MaterialApp(
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
        ),
      ),
    );
    if (Platform.isWindows) {
      setWindowTitle('아카콘 다운로더');
    }
  } else {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://arca.live/e/'));
    runApp(
      MaterialApp(
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
      ),
    );
  }
}

late WebViewController controller;

extension WebViewControllerExtension on WebViewController {
  Future<String> getHtml() {
    return runJavaScriptReturningResult('document.documentElement.outerHTML')
        .then((value) {
      if (Platform.isAndroid) {
        return jsonDecode(value as String) as String;
      } else {
        return value as String;
      }
    });
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('아카콘 다운로더'),
          actions: [
            IconButton(
              onPressed: () async {
                var html = await controller.getHtml();
                var curUrl = await controller.currentUrl();
                singleStartDownloadFromHtml(null, html, curUrl, null, null);
              },
              icon: const Icon(Icons.download),
            )
          ],
        ),
        body: WebViewWidget(controller: controller),
      ),
      onPopInvoked: (didPop) {
        controller.canGoBack().then(
          (value) {
            if (value) {
              controller.goBack();
            } else {
              showDialog(
                builder: (context) {
                  return AlertDialog(
                    title: const Text('앱 종료'),
                    content: const Text('앱을 종료하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          SystemNavigator.pop(animated: true);
                        },
                        child: const Text('확인'),
                      )
                    ],
                  );
                },
                context: context,
              );
            }
          },
        );
      },
    );
  }
}

void initPythonScript() {
  var exePath = Platform.resolvedExecutable.toString();
  var exeDirectory =
      exePath.replaceRange(exePath.lastIndexOf('\\') + 1, null, '');
  var pyDirectory = '$exeDirectory\\res';

  var script =
      "import imageio\nimport imageio_ffmpeg\nimport ffmpeg\nimport sys\n\n\ndef convertFile(inputpath, outputpath, palettepath):\n\treader = imageio.get_reader(inputpath)\n\tfps = reader.get_meta_data()['fps']\n\t# print(outputpath + '원본 fps: ' + str(fps))\n\twhile fps > 50:\n\t\tfps = fps/2\n\t\t# print('조정 fps: ' + str(fps))\n\tffmpeg.input(inputpath).filter(filter_name='palettegen').output(palettepath, loglevel='error').global_args('-hide_banner').overwrite_output().run(cmd=imageio_ffmpeg.get_ffmpeg_exe())\n\tffmpeg.filter([ffmpeg.input(inputpath), ffmpeg.input(palettepath)], filter_name='paletteuse').output(outputpath, r=fps, loglevel='error').global_args('-hide_banner').overwrite_output().run(cmd=imageio_ffmpeg.get_ffmpeg_exe())\n\n\nconvertFile(sys.argv[1], sys.argv[2], sys.argv[3])";
  var file = File('$pyDirectory\\convert.py');
  file.createSync(recursive: true);
  file.writeAsStringSync(script, flush: true);
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
        int x, y;
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

        if (x > y) {
          // 앱 버전이 큼
          needUpdate = false;
          break;
        } else if (x < y) {
          // 비교 버전이 큼
          needUpdate = true;
          break;
        } else {
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
  const ArcaconDownloader({super.key});

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
                      /*launchURLtoBrowser(context,
                          'https://play.google.com/store/apps/details?id=com.ppaka.ArcaconDownloader');*/
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

  void showStartAlert() {
    if (isGooglePlay) {
      showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('안내'),
            content:
                const Text('아카콘 다운로더의 사용 불가에 대해서, \'자세히\' 버튼을 눌러 확인해주시기 바랍니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('자세히'),
                onPressed: () {
                  Navigator.pop(context);
                  launchURLtoBrowser(context,
                      'https://github.com/ppaka/arcacon_downloader/blob/master/ForGooglePlay.md');
                },
              ),
              TextButton(
                child: const Text('닫기'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    } else {
      showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('사용하기 전에'),
            content: const Text(
                '로그인 후, 아카콘 페이지에서 원하는 아카콘을 선택하고 오른쪽 상단의 다운로드 버튼을 누릅니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showStartAlert();
      var hasUpdate = await checkUpdate();
      if (hasUpdate) showUpdateDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    if (isGooglePlay) {
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
    } else {
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
          home: const HomeScreen(),
        ),
      );
    }
  }
}
