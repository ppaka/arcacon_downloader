import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

import '../route/con_page.dart';
import '../utility/string_converter.dart';

int lastLoadPage = 0;
int nowWorkingPage = -1;
late int lastPage;
List<PreviewArcaconItem> previewList = [];
late Future<List<PreviewArcaconItem>> items;
bool sortByRank = false;

enum SearchFilter { title, nickname, tag }

SearchFilter searchFilter = SearchFilter.title;
String searchString = "";

class PreviewArcaconItem {
  final String pageUrl;
  final String imageUrl;
  String title, count, maker;

  PreviewArcaconItem(
      this.pageUrl, this.imageUrl, this.title, this.count, this.maker);
}

ScrollController? scrollController;

void scrollToZero() {
  scrollController?.animateTo(0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart);
}

Future<List<PreviewArcaconItem>> loadPage(bool loadFirstPage) {
  if (loadFirstPage) {
    return Future<List<PreviewArcaconItem>>(() async {
      int targetPage = 1;
      nowWorkingPage = 1;
      String url = "https://arca.live/e/?p=$targetPage";

      if (searchString != "") {
        if (searchFilter == SearchFilter.title) {
          url += "&target=title";
          url += "&keyword=$searchString";
        } else if (searchFilter == SearchFilter.nickname) {
          url += "&target=nickname";
          url += "&keyword=$searchString";
        } else {
          url += "&target=tag";
          url += "&keyword=$searchString";
        }
      }

      if (sortByRank) url += "&sort=rank";

      http.Client client = http.Client();
      http.Response response = await client.get(Uri.parse(url));
      var document = parser.parse(response.body);

      dom.Element? lastPageDocu = document.querySelector(
          'body > div.root-container > div.content-wrapper.clearfix > article > div > div > nav > ul');
      var lastPageLinkBody = lastPageDocu!
          .children[lastPageDocu.children.length - 1]
          .children[0]
          .attributes['href'];
      var lastPageNumber = Uri.parse(lastPageLinkBody!).queryParameters['p'];
      lastPage = int.parse(lastPageNumber!);

      previewList.clear();

      dom.Element? parsed = document.querySelector(
          'body > div.root-container > div.content-wrapper.clearfix > article > div > div > div.emoticon-list');
      if (parsed == null) return previewList;
      parsed.children.removeAt(0);

      for (var element in parsed.children) {
        String title = element.children[0].children[1].children[0].text;
        if (element.children[0].children[1].children[0].outerHtml
            .contains('[email&nbsp;protected]')) {
          // debugPrint('$title-> 제목 변환');
          title = element.children[0].children[1].children[0].outerHtml
              .replaceAll('<div class="title">', '');
          title = title.replaceAll('</div>', '');
          title = convertEncodedTitleForList(title);
        }

        String count = element.children[0].children[1].children[1].text;
        String maker = element.children[0].children[1].children[2].text;
        // debugPrint(title);
        previewList.add(
          PreviewArcaconItem(
              "https://arca.live${element.attributes['href']!}",
              "https:${element.children[0].children[0].attributes['src']!}",
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

    if (searchString != "") {
      if (searchFilter == SearchFilter.title) {
        url += "&target=title";
        url += "&keyword=$searchString";
      } else if (searchFilter == SearchFilter.nickname) {
        url += "&target=nickname";
        url += "&keyword=$searchString";
      } else {
        url += "&target=tag";
        url += "&keyword=$searchString";
      }
    }

    if (sortByRank) url += "&sort=rank";

    // debugPrint(url);

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
        // debugPrint('$title-> 제목 변환');
        title = element.children[0].children[1].children[0].outerHtml
            .replaceAll('<div class="title">', '');
        title = title.replaceAll('</div>', '');
        title = convertEncodedTitleForList(title);
      }

      String count = element.children[0].children[1].children[1].text;
      String maker = element.children[0].children[1].children[2].text;
      //debugPrint(title);
      previewList.add(PreviewArcaconItem(
          "https://arca.live${element.attributes['href']!}",
          "https:${element.children[0].children[0].attributes['src']!}",
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
  ArcaconPageState createState() => ArcaconPageState();
}

class ArcaconPageState extends State<ArcaconPage>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController searchTextController;

  Future<void> requestNew() async {
    previewList.clear();
    setState(() {
      items = loadPage(true).whenComplete(() {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          for (int i = 0; i < 5; i++) {
            if (!scrollController!.hasClients) break;
            if (scrollController!.offset >
                scrollController!.position.maxScrollExtent -
                    MediaQuery.of(context).size.height *
                        MediaQuery.of(context).devicePixelRatio) {
              await requestMore();
              setState(() {});
            }
          }
        });
      });
    });
  }

  Future<void> requestMore() async {
    await loadPage(false).onError((error, stackTrace) {
      debugPrint(error.toString());
      return previewList;
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    searchTextController = TextEditingController();
    items = loadPage(true).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        for (int i = 0; i < 5; i++) {
          if (!scrollController!.hasClients) break;
          if (!scrollController!.position.hasContentDimensions) {
            return;
          }
          if (scrollController!.offset >
              scrollController!.position.maxScrollExtent -
                  MediaQuery.of(context).size.height *
                      MediaQuery.of(context).devicePixelRatio) {
            await requestMore();
            setState(() {});
          }
        }
      });
    });

    scrollController?.addListener(() {
      if (!scrollController!.position.hasContentDimensions) {
        return;
      }
      if (scrollController!.offset >
          scrollController!.position.maxScrollExtent -
              MediaQuery.of(context).size.height *
                  MediaQuery.of(context).devicePixelRatio) {
        requestMore().then((value) => setState(() {}));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController?.dispose();
    searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchTextController,
          onSubmitted: (value) {
            searchString = value;
            if (scrollController!.hasClients) {
              scrollController?.jumpTo(0);
            }
            requestNew();
          },
          decoration: InputDecoration(
              labelText: '검색',
              suffixIcon: IconButton(
                  onPressed: () {
                    searchString = searchTextController.text;
                    if (scrollController!.hasClients) {
                      scrollController?.jumpTo(0);
                    }
                    requestNew();
                  },
                  icon: const Icon(Icons.search))),
        ),
        actions: [
          PopupMenuButton(
              tooltip: '',
              icon: const Icon(Icons.filter_list_rounded),
              itemBuilder: (context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: '제목',
                    child: const Text('제목'),
                    onTap: () {
                      searchFilter = SearchFilter.title;
                      if (searchString != "") {
                        try {
                          if (scrollController!.hasClients) {
                            scrollController?.jumpTo(0);
                          }
                        } finally {
                          requestNew();
                        }
                      }
                    },
                  ),
                  PopupMenuItem<String>(
                    value: '판매자',
                    child: const Text('판매자'),
                    onTap: () {
                      searchFilter = SearchFilter.nickname;
                      if (searchString != "") {
                        try {
                          if (scrollController!.hasClients) {
                            scrollController?.jumpTo(0);
                          }
                        } finally {
                          requestNew();
                        }
                      }
                    },
                  ),
                  PopupMenuItem<String>(
                    value: '태그',
                    child: const Text('태그'),
                    onTap: () {
                      searchFilter = SearchFilter.tag;
                      if (searchString != "") {
                        try {
                          if (scrollController!.hasClients) {
                            scrollController?.jumpTo(0);
                          }
                        } finally {
                          requestNew();
                        }
                      }
                    },
                  ),
                ];
              }),
          PopupMenuButton(
              tooltip: '',
              icon: const Icon(Icons.sort_rounded),
              itemBuilder: (context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem(
                    child: const Text('등록순'),
                    onTap: () {
                      sortByRank = false;
                      try {
                        if (scrollController!.hasClients) {
                          scrollController?.jumpTo(0);
                        }
                      } finally {
                        requestNew();
                      }
                    },
                  ),
                  PopupMenuItem(
                    child: const Text('판매순'),
                    onTap: () {
                      sortByRank = true;
                      try {
                        if (scrollController!.hasClients) {
                          scrollController?.jumpTo(0);
                        }
                      } finally {
                        requestNew();
                      }
                    },
                  ),
                ];
              }),
        ],
      ),
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
                        borderOnForeground: false,
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0)),
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConPage(
                                  item: snapshot.data![position],
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (snapshot.data![position].imageUrl
                                  .contains('mp4'))
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: const SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Icon(Icons.play_circle,
                                          color: Colors.red, size: 50)),
                                )
                              else
                                Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          snapshot.data![position].imageUrl,
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                                child: Text(
                                  snapshot.data![position].title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                child: Text(
                                  snapshot.data![position].maker,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
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
              if (snapshot.data == null) {
                return Text(
                  "아무 데이터도 찾을 수 없었습니다...\n${snapshot.error}",
                  textAlign: TextAlign.center,
                );
              } else {
                return Text("${snapshot.error}");
              }
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
