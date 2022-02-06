import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ArcaconPage extends StatefulWidget {
  const ArcaconPage({Key? key}) : super(key: key);

  @override
  _ArcaconListPage createState() => _ArcaconListPage();
}

int lastLoadPage = 0;
int nowWorkingPage = -1;
late int lastPage;
List<PreviewArcaconItem> previewList = [];
Map<int, VideoPlayerControllerItem> videoControllers = {};
late Future<List<PreviewArcaconItem>> items;

class VideoPlayerControllerItem {
  late VideoPlayerController controller;
  late bool isPlaying;
}

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
    return Future<List<PreviewArcaconItem>>.delayed(const Duration(seconds: 0),
        () async {
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
          print(title + '-> 제목 변환');
          title = element.children[0].children[1].children[0].outerHtml
              .replaceAll('<div class="title">', '');
          title = title.replaceAll('</div>', '');
          title = _convertEncodedTitle(title);
        }

        String count = element.children[0].children[1].children[1].text;
        String maker = element.children[0].children[1].children[2].text;
        print(title);
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

  return Future<List<PreviewArcaconItem>>.delayed(const Duration(seconds: 0),
      () async {
    int targetPage = lastLoadPage + 1;
    if (targetPage == lastPage) {
      return previewList;
    }
    if (nowWorkingPage == targetPage) {
      return previewList;
    }
    nowWorkingPage = targetPage;
    String url = "https://arca.live/e/?p=$targetPage";
    print(url);

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
        print(title + '-> 제목 변환');
        title = element.children[0].children[1].children[0].outerHtml
            .replaceAll('<div class="title">', '');
        title = title.replaceAll('</div>', '');
        title = _convertEncodedTitle(title);
      }

      String count = element.children[0].children[1].children[1].text;
      String maker = element.children[0].children[1].children[2].text;
      print(title);
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

class PreviewArcaconItem {
  final String pageUrl;
  final String imageUrl;
  final String title, count, maker;
  PreviewArcaconItem(
      this.pageUrl, this.imageUrl, this.title, this.count, this.maker);
}

Future<void> requestMore() async {
  // 해당부분은 서버에서 가져오는 내용을 가상으로 만든 것이기 때문에 큰 의미는 없다.

  // 읽을 데이터 위치 얻기
  /*int nextDataPosition = (nextPage * 10);
  // 읽을 데이터 크기
  int dataLength = 10;

  // 읽을 데이터가 서버에 있는 데이터 총 크기보다 크다면 더이상 읽을 데이터가 없다고 판다.
  if (nextDataPosition > serverItems.length) {
    // 더이상 가져갈 것이 없음
    return;
  }

  // 읽을 데이터는 있지만 10개가 안되는 경우
  if ((nextDataPosition + 10) > serverItems.length) {
    // 가능한 최대 개수 얻기
    dataLength = serverItems.length - nextDataPosition;
  }
  setState(() {
    // 데이터 읽기
    items +=
        serverItems.sublist(nextDataPosition, nextDataPosition + dataLength);

    // 다음을 위해 페이지 증가
    nextPage += 1;
  });*/

  await loadPage(false).onError((error, stackTrace) {
    print(error);
    return previewList;
  });

  // 가상으로 잠시 지연 줌
  return await Future.delayed(const Duration(milliseconds: 0));
}

class _ArcaconListPage extends State<ArcaconPage> {
  Future<void> requestNew() async {
    previewList.clear();
    videoControllers.forEach((key, value) {
      value.controller.dispose();
    });
    videoControllers.clear();
    setState(() {
      items = loadPage(true);
    });

    /*nextPage = 0;
  items.clear();
  setState(() {
    items += serverItems.sublist(nextPage * 10, (nextPage * 10) + 10);
    // 다음을 위해 페이지 증가
    nextPage += 1;
  });*/

    // 데이터 가져오는 동안 효과를 보여주기 위해 약 1초간 대기하는 것
    // 실제 서버에서 가져올땐 필요없음
    return await Future.delayed(const Duration(milliseconds: 1000));
  }

  double _dragDistance = 0;

  scrollNotification(notification) {
    // 스크롤 최대 범위
    var containerExtent = notification.metrics.viewportDimension;

    if (notification is ScrollStartNotification) {
      // 스크롤을 시작하면 발생(손가락으로 리스트를 누르고 움직이려고 할때)
      // 스크롤 거리값을 0으로 초기화함
      _dragDistance = 0;
    } else if (notification is OverscrollNotification) {
      // 안드로이드에서 동작
      // 스크롤을 시작후 움직일때 발생(손가락으로 리스트를 누르고 움직이고 있을때 계속 발생)
      // 스크롤 움직인 만큼 빼준다.(notification.overscroll)
      _dragDistance -= notification.overscroll;
    } else if (notification is ScrollUpdateNotification) {
      // ios에서 동작
      // 스크롤을 시작후 움직일때 발생(손가락으로 리스트를 누르고 움직이고 있을때 계속 발생)
      // 스크롤 움직인 만큼 빼준다.(notification.scrollDelta)
      _dragDistance -= notification.scrollDelta!;
    } else if (notification is ScrollEndNotification) {
      // 스크롤이 끝났을때 발생(손가락을 리스트에서 움직이다가 뗐을때 발생)

      // 지금까지 움직인 거리를 최대 거리로 나눈다.
      var percent = _dragDistance / (containerExtent);
      // 해당 값이 -0.4(40프로 이상) 아래서 위로 움직였다면
      if (percent <= -0.4) {
        // maxScrollExtent는 리스트 가장 아래 위치 값
        // pixels는 현재 위치 값
        // 두 같이 같다면(스크롤이 가장 아래에 있다)
        if (notification.metrics.maxScrollExtent ==
            notification.metrics.pixels) {
          print("데이터 로드");

          setState(() {
            // 서버에서 데이터를 더 가져오는 효과를 주기 위함
            // 하단에 프로그레스 서클 표시용
            // isMoreRequesting = true;
          });

          // 서버에서 데이터 가져온다.
          requestMore().then((value) {
            setState(() {
              // 다 가져오면 하단 표시 서클 제거
              // isMoreRequesting = false;
            });
          });
        }
      }
    }
  }

  Future<Image> loadThumbnailImage(AsyncSnapshot snapshot, int index) {
    return Future<Image>.delayed(const Duration(seconds: 0), () async {
      var thumbnail = await VideoThumbnail.thumbnailData(
        video: snapshot.data![index].imageUrl,
        imageFormat: ImageFormat.PNG,
        maxWidth: 100,
        maxHeight: 100,
        timeMs: 0,
        quality: 100,
      );

      return Image.memory(thumbnail!);
    });
  }

  Future<VideoPlayerController> loadVideo(AsyncSnapshot snapshot, int index) {
    return Future<VideoPlayerController>.delayed(
      const Duration(seconds: 0),
      () async {
        VideoPlayerController controller = VideoPlayerController.network(
          snapshot.data![index].imageUrl,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        controller.initialize();
        controller.setLooping(true);
        controller.pause();

        videoControllers[index]!.controller = controller;
        videoControllers[index]!.isPlaying = true;

        return controller;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    items = loadPage(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: items,
          builder: (context, AsyncSnapshot<List<PreviewArcaconItem>> snapshot) {
            if (snapshot.hasData) {
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  scrollNotification(notification);
                  return false;
                },
                child: RefreshIndicator(
                  onRefresh: requestNew,
                  child: GridView.builder(
                    itemBuilder: (context, position) {
                      return Card(
                        child: SizedBox(
                          height: 10,
                          width: 50,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10.0,
                              ),
                              if (snapshot.data![position].imageUrl
                                  .endsWith('mp4'))
                                SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: /*FutureBuilder(
                                    future: loadVideo(snapshot, position),
                                    builder: (context,
                                        AsyncSnapshot<VideoPlayerController>
                                            snapshot) {
                                      if (snapshot.hasData) {
                                        print("영상있음");
                                        //return VideoPlayer(snapshot.data!);
                                        return const CircularProgressIndicator();
                                        */ /*return VisibilityDetector(
                                          key: UniqueKey(),
                                          child: videoControllers[position]!
                                              .player,
                                          onVisibilityChanged: (info) {
                                            videoControllers[position]!
                                                .player
                                                .controller
                                                .onPlayerVisibilityChanged(
                                                    info.visibleFraction);
                                            */ /* */ /*if (info.visibleFraction == 0) {
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
                                          }*/ /* */ /*
                                          });*/ /*
                                      }

                                      print('영상 없음');
                                      return const CircularProgressIndicator();
                                    },
                                  ),*/
                                        FutureBuilder(
                                            future: loadThumbnailImage(
                                                snapshot, position),
                                            builder: (context,
                                                AsyncSnapshot<Image> snapshot) {
                                              if (snapshot.hasData) {
                                                return snapshot.data!;
                                              } else if (snapshot.hasError) {
                                                return const Icon(Icons.warning,
                                                    color: Colors.red,
                                                    size: 50);
                                              }
                                              return const CircularProgressIndicator();
                                            }))
                              else
                                Image.network(
                                  snapshot.data![position].imageUrl,
                                  width: 100,
                                  height: 100,
                                  errorBuilder: (BuildContext context,
                                      Object obj, StackTrace? trace) {
                                    return const Center(
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Icon(
                                          Icons.error,
                                          size: 50,
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  },
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Center(
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                child: Text(
                                  snapshot.data![position].title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Container(
                                child: Text(
                                  snapshot.data![position].maker,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              ),
                            ],
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      );
                    },
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150,
                      //crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                      childAspectRatio: 1 / 1.4, //item 의 가로 1, 세로 2 의 비율
                      mainAxisSpacing: 10, //수평 Padding
                      crossAxisSpacing: 10, //수직 Padding
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
}
