import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
// import 'package:arcacon_downloader/utility/video.dart';
// import 'package:video_player/video_player.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

int lastLoadPage = 0;
int nowWorkingPage = -1;
late int lastPage;
List<PreviewArcaconItem> previewList = [];
late Future<List<PreviewArcaconItem>> items;
//Map<int, VideoPlayerControllerItem> videoControllers = {};

class PreviewArcaconItem {
  final String pageUrl;
  final String imageUrl;
  final String title, count, maker;

  PreviewArcaconItem(
      this.pageUrl, this.imageUrl, this.title, this.count, this.maker);
}

// class VideoPlayerControllerItem {
//   late VideoPlayerController controller;
//   late bool isPlaying;
// }

String _convertEncodedTitle(String titleText) {
  for (int j = 0; j < titleText.length; j++) {
    if (titleText.contains('<span class="__cf_email__"')) {
      var lastIndex = titleText.lastIndexOf('<span class="__cf_email__"');
      var endIndex = titleText.lastIndexOf('</span>') + 7;
      var emailSource = titleText.substring(lastIndex, endIndex);

      var valueStartIndex = emailSource.lastIndexOf('data-cfemail="') + 14;
      var valueEndIndex = emailSource.lastIndexOf('">[email&nbsp;protected]');

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

Future<List<PreviewArcaconItem>> loadPage(bool loadFirstPage) {
  if (loadFirstPage) {
    return Future<List<PreviewArcaconItem>>(() async {
      int targetPage = 1;
      nowWorkingPage = 1;
      String url = "https://arca.live/e/?p=$targetPage";

      http.Client client = http.Client();
      http.Response response = await client.get(Uri.parse(url));
      var document = parser.parse(response.body);

      dom.Element? lastPageDocu = document.querySelector(
          'body > div.root-container > div.content-wrapper.clearfix > article > div > div > nav > ul');
      var lastPageLinkBody = lastPageDocu!
          .children[lastPageDocu.children.length - 1]
          .children[0]
          .attributes['href'];
      var lastPageNumber = lastPageLinkBody!.replaceAll('/e/?p=', '');
      lastPage = int.parse(lastPageNumber);

      dom.Element? parsed = document.querySelector(
          'body > div.root-container > div.content-wrapper.clearfix > article > div > div > div.emoticon-list');
      parsed!.children.removeAt(0);
      previewList.clear();

      for (var element in parsed.children) {
        String title = element.children[0].children[1].children[0].text;
        if (element.children[0].children[1].children[0].outerHtml
            .contains('[email&nbsp;protected]')) {
          debugPrint(title + '-> 제목 변환');
          title = element.children[0].children[1].children[0].outerHtml
              .replaceAll('<div class="title">', '');
          title = title.replaceAll('</div>', '');
          title = _convertEncodedTitle(title);
        }

        String count = element.children[0].children[1].children[1].text;
        String maker = element.children[0].children[1].children[2].text;
        debugPrint(title);
        previewList.add(
          PreviewArcaconItem(
              "https://arca.live" + element.attributes['href']!,
              "https:" + element.children[0].children[0].attributes['src']!,
              title,
              count,
              maker),
        );
      }

      lastLoadPage = 1;
      return previewList;
    });
  }

  return Future<List<PreviewArcaconItem>>(() async {
    int targetPage = lastLoadPage + 1;
    if (targetPage == lastPage) {
      return previewList;
    }
    if (nowWorkingPage == targetPage) {
      return previewList;
    }
    nowWorkingPage = targetPage;
    String url = "https://arca.live/e/?p=$targetPage";
    debugPrint(url);

    http.Client client = http.Client();
    http.Response response = await client.get(Uri.parse(url));
    var document = parser.parse(response.body);

    dom.Element? parsed = document.querySelector(
        'body > div.root-container > div.content-wrapper.clearfix > article > div > div > div.emoticon-list');
    parsed!.children.removeAt(0);

    for (var element in parsed.children) {
      String title = element.children[0].children[1].children[0].text;
      if (element.children[0].children[1].children[0].outerHtml
          .contains('[email&nbsp;protected]')) {
        debugPrint(title + '-> 제목 변환');
        title = element.children[0].children[1].children[0].outerHtml
            .replaceAll('<div class="title">', '');
        title = title.replaceAll('</div>', '');
        title = _convertEncodedTitle(title);
      }

      String count = element.children[0].children[1].children[1].text;
      String maker = element.children[0].children[1].children[2].text;
      debugPrint(title);
      previewList.add(PreviewArcaconItem(
          "https://arca.live" + element.attributes['href']!,
          "https:" + element.children[0].children[0].attributes['src']!,
          title,
          count,
          maker));
    }

    lastLoadPage++;
    return previewList;
  });
}

class ArcaconPage extends StatefulWidget {
  const ArcaconPage({Key? key}) : super(key: key);

  @override
  _ArcaconPageState createState() => _ArcaconPageState();
}

class _ArcaconPageState extends State<ArcaconPage>
    with AutomaticKeepAliveClientMixin {
  Future<void> requestNew() async {
    previewList.clear();
    // videoControllers.forEach((key, value) {
    //   value.controller.dispose();
    // });
    // videoControllers.clear();
    setState(() {
      items = loadPage(true);
    });
  }

  Future<void> requestMore() async {
    await loadPage(false).onError((error, stackTrace) {
      debugPrint(error.toString());
      return previewList;
    });
  }

  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    items = loadPage(true);
    scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.offset >
          scrollController.position.maxScrollExtent * 0.4) {
        requestMore().then((value) => setState(
              () {},
            ));
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('목록'),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: FutureBuilder(
          future: items,
          builder: (context, AsyncSnapshot<List<PreviewArcaconItem>> snapshot) {
            if (snapshot.hasData) {
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: RefreshIndicator(
                  onRefresh: requestNew,
                  child: GridView.builder(
                    controller: scrollController,
                    itemBuilder: (context, position) {
                      return Card(
                        child: GestureDetector(
                          onTap: () {
                            debugPrint('누름');
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (snapshot.data![position].imageUrl
                                    .endsWith('mp4'))
                                  Container(
                                    child: const SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: /*FutureBuilder(
                                        future: loadVideo(snapshot, position),
                                        builder: (context,
                                            AsyncSnapshot<VideoPlayerController>
                                                snapshot) {
                                          if (snapshot.hasData) {
                                            debugPrint("영상있음");
                                            //return VideoPlayer(snapshot.data!);
                                            return const CircularProgressIndicator();
                                            return VisibilityDetector(
                                              key: UniqueKey(),
                                              child: videoControllers[position]!
                                                  .player,
                                              onVisibilityChanged: (info) {
                                                videoControllers[position]!
                                                    .player
                                                    .controller
                                                    .onPlayerVisibilityChanged(
                                                        info.visibleFraction);
                                                if (info.visibleFraction == 0) {
                                                videoControllers[position]!
                                                    .player
                                                    .controller
                                                    .pause();
                                                videoControllers[position]!
                                                    .isPlaying = false;
                                              } else {
                                                if (videoControllers[position]!
                                                        .isPlaying ==
                                                    false) {
                                                  videoControllers[position]!
                                                      .player
                                                      .controller
                                                      .play();
                                                  videoControllers[position]!
                                                      .isPlaying = true;
                                                }
                                              }
                                              });
                                          }

                                          debugPrint('영상 없음');
                                          return const CircularProgressIndicator();
                                        },
                                      ),*/
                                            // FutureBuilder(
                                            //     future: loadThumbnailImage(
                                            //         snapshot, position),
                                            //     builder: (context,
                                            //         AsyncSnapshot<Image>
                                            //             snapshot) {
                                            //       if (snapshot.hasData) {
                                            //         return snapshot.data!;
                                            //       } else if (snapshot.hasError) {
                                            //         return const Icon(
                                            //             Icons.play_circle,
                                            //             color: Colors.red,
                                            //             size: 50);
                                            //       }
                                            //       return const CircularProgressIndicator();
                                            //     }),
                                            Icon(Icons.play_circle,
                                                color: Colors.red, size: 50)),
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  )
                                else
                                  Container(
                                    child: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            snapshot.data![position].imageUrl,
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  ),
                                Container(
                                  child: Text(
                                    snapshot.data![position].title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  margin:
                                      const EdgeInsets.fromLTRB(5, 10, 5, 0),
                                ),
                                Container(
                                  child: Text(
                                    snapshot.data![position].maker,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                ),
                              ],
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        borderOnForeground: false,
                        elevation: 10,
                      );
                    },
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150,
                      mainAxisSpacing: 7, //수평 Padding
                      crossAxisSpacing: 7, //수직 Padding
                      mainAxisExtent: 180,
                      //childAspectRatio: (itemWidth / itemHeight), //item 의 가로 1, 세로 2 의 비율
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
