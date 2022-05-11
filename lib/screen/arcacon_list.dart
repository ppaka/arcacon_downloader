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

class PreviewArcaconItem {
  final String pageUrl;
  final String imageUrl;
  final String title, count, maker;

  PreviewArcaconItem(
      this.pageUrl, this.imageUrl, this.title, this.count, this.maker);
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
          title = convertEncodedTitleForList(title);
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
        title = convertEncodedTitleForList(title);
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
    setState(() {
      items = loadPage(true);
      if (scrollController.offset >
          scrollController.position.maxScrollExtent -
              MediaQuery.of(context).size.height *
                  MediaQuery.of(context).devicePixelRatio) {
        requestMore().then((value) => setState(() {}));
      }
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
    items = loadPage(true).whenComplete(() => requestMore());
    scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.offset >
          scrollController.position.maxScrollExtent -
              MediaQuery.of(context).size.height *
                  MediaQuery.of(context).devicePixelRatio) {
        requestMore().then((value) => setState(() {}));
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ConPage(
                                        item: snapshot.data![position],
                                      )),
                            );
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
                                        child: Icon(Icons.play_circle,
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
