import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.white,
    skipTaskbar: false,
    title: "아카콘 다운로더",
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.setMaximizable(false);
  await windowManager.setMinimizable(true);
  await windowManager.setResizable(false);

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const AppRoot());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown
      };
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arcacon Downloader',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.dark,
      home: const MainPage(title: '아카콘 다운로더'),
    );
  }
}

class Arcacon {
  final int id;
  final String imageUrl;

  Arcacon({required this.id, required this.imageUrl});

  factory Arcacon.fromJson(Map<String, dynamic> json) {
    return Arcacon(
      id: json['id'] as int,
      imageUrl: 'https:${json['imageUrl']}',
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class ArcaconList extends StatelessWidget {
  const ArcaconList(
      {super.key, required this.arcacons, required this.controller});
  final List<Arcacon> arcacons;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        controller: controller,
        itemCount: arcacons.length,
        itemBuilder: (context, index) {
          var arcacon = arcacons[index];
          return CachedNetworkImage(
            imageUrl: arcacon.imageUrl,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        },
      ),
    );
  }
}

class _MainPageState extends State<MainPage> {
  Future<List<Arcacon>> fetchArcacon(String shopPageUrl) async {
    Client client = Client();

    var arcaconShopId = shopPageUrl.split('/').last.split('?').first;
    if (int.tryParse(arcaconShopId) == null) {
      return [];
    }

    final response = await client.get(
      Uri.parse("https://arca.live/api/app/list/emoticon/$arcaconShopId"),
      headers: {
        "User-Agent": "live.arca.android/0.8.369",
        "Host": "arca.live",
        "X-Device-Token": "",
      },
    );
    // return await compute(parseArcacon, response.body);
    return parseArcacon(response.body);
  }

  List<Arcacon> parseArcacon(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Arcacon>((json) => Arcacon.fromJson(json)).toList();
  }

  void downloadArcacons(String shopPageUrl) async {
    var arcaconShopId = shopPageUrl.split('/').last.split('?').first;
    var dio = Dio();

    setState(() {
      taskPercent = Future.value(-1);
    });
    final arcacons = await fetchArcacon(shopPageUrl);
    final lengthChrCount = arcacons.length.toString().length;
    var downloadsDirectory = await getDownloadsDirectory();
    var directoryStr = "${downloadsDirectory!.path}/$arcaconShopId";
    var directory = await Directory(directoryStr).create();

    setState(() {
      taskPercent = Future.value(0);
    });

    for (int i = 0; i < arcacons.length; i++) {
      var con = arcacons[i];
      var fileExtension = con.imageUrl.split('?').first.split('.').last;
      var filename =
          "${(i + 1).toString().padLeft(lengthChrCount, '0')}.$fileExtension";
      await dio.download(con.imageUrl, "${directory.path}/$filename");

      setState(() {
        taskPercent = Future.value(i + 1 / arcacons.length);
      });
    }

    setState(() {
      taskPercent = Future.value(null);
    });
  }

  late Future<List<Arcacon>> myFuture;
  late TextEditingController textEditingController = TextEditingController();
  late ScrollController controller = ScrollController();
  late Future<double?> taskPercent = Future.value(null);

  Widget singleTaskButton() {
    return FutureBuilder<double?>(
      future: taskPercent,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return SizedBox(
            width: 800,
            height: 36,
            child: FilledButton(
              onPressed: () {
                downloadArcacons(textEditingController.text);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('다운로드'),
            ),
          );
        } else {
          if (snapshot.data! < 0) {
            return LinearProgressIndicator(
              borderRadius: BorderRadius.circular(10),
              minHeight: 36,
              value: null,
            );
          }
          return LinearProgressIndicator(
            borderRadius: BorderRadius.circular(10),
            minHeight: 36,
            value: snapshot.data,
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    myFuture = fetchArcacon('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            color: Colors.black,
            width: 800,
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            alignment: Alignment.center,
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: textEditingController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: '아카콘 주소',
                      hintText: '상점 페이지 URL을 입력해주세요',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      filled: true,
                    ),
                    keyboardType: TextInputType.url,
                    onSubmitted: (value) {
                      setState(() {
                        myFuture = fetchArcacon(value);
                        controller.position.moveTo(
                          0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                        );
                      });
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        myFuture = fetchArcacon(textEditingController.text);
                        controller.position.moveTo(
                          0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 800,
            height: 600 - 160,
            color: Colors.white12,
            child: FutureBuilder<List<Arcacon>>(
              future: myFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  if (kDebugMode) {
                    print(snapshot.error);
                  }
                }
                if (snapshot.data != null) {
                  if (snapshot.hasData) {
                    return ArcaconList(
                      arcacons: snapshot.data!,
                      controller: controller,
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                } else {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                    ),
                  );
                }
              },
            ),
          ),
          Container(
            color: Colors.transparent,
            width: 800,
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            alignment: Alignment.center,
            child: singleTaskButton(),
          ),
        ],
      ),
    );
  }
}
