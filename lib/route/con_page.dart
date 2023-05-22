import 'dart:io';

import 'package:arcacon_downloader/utility/string_converter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

import '../screen/arcacon_list.dart';
import '../screen/first_page.dart';
import '../utility/custom_tab.dart';
import 'image_detail.dart';

class ConLists {
  List<String> arcacon = [];
  List<String> arcaconTrueUrl = [];
}

Future<ConLists> getCons(String url) async {
  var client = http.Client();
  var lists = ConLists();

  http.Response response;
  try {
    response = await client.get(Uri.parse(url));
  } catch (ex) {
    debugPrint(ex.toString());
    return lists;
  }

  var document = parser.parse(response.body);
  dom.Element? title = document.querySelector(
      'body > div.root-container > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-head > div.title-row > div');

  var titleText = title!.outerHtml.split('\n')[1];

  if (titleText.contains('[email&nbsp;protected]')) {
    titleText = convertEncodedTitleForList(titleText);
  }

  titleText = titleText.trim();
  var invalidChar = RegExp(r'[\/:*?"<>|]');
  if (invalidChar.hasMatch(titleText)) {
    titleText = titleText.replaceAll(invalidChar, '');
  }

  dom.Element links = document.querySelector(
      'body > div > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-body > div')!;

  for (var element in links.children) {
    if (element.toString().startsWith('<div')) {
      break;
    }

    if (element.attributes['poster'].toString() != "null") {
      var uri = 'https:${element.attributes['poster']}';
      var convertedUri = uri.replaceRange(uri.indexOf('?'), uri.length, '');
      lists.arcacon.add(convertedUri);
      lists.arcaconTrueUrl.add(uri);
      continue;
    }
    if (element.attributes['src'].toString() != "null") {
      var uri = 'https:${element.attributes['src']}';
      var convertedUri = uri.replaceRange(uri.indexOf('?'), uri.length, '');
      lists.arcacon.add(convertedUri);
      lists.arcaconTrueUrl.add(uri);
      continue;
    }
  }
  return lists;
}

late Future<ConLists> items;

class ConPage extends StatefulWidget {
  ConPage({Key? key, PreviewArcaconItem? item}) : super(key: key) {
    this.item = item!;
  }

  late final PreviewArcaconItem item;

  @override
  State<ConPage> createState() => _ConPageState();
}

class _ConPageState extends State<ConPage> {
  @override
  void initState() {
    items = getCons(widget.item.pageUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var key = UniqueKey().toString();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(children: [
        Row(
          children: [
            widget.item.imageUrl.contains('.mp4')
                ? Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: const SizedBox(
                        width: 100,
                        height: 100,
                        child: Icon(
                          Icons.play_circle,
                          color: Colors.red,
                          size: 50,
                        )),
                  )
                : Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: GestureDetector(
                      onTap: () {
                        navigateToImageDetailPage(
                            context, widget.item.imageUrl, key);
                      },
                      child: Hero(
                        tag: key,
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: CachedNetworkImage(
                            imageUrl: widget.item.imageUrl,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40 - 100,
                  child: Text(
                    widget.item.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.clip,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40 - 100,
                  child: Text(
                    widget.item.maker,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width - 40,
          child: ElevatedButton(
              onPressed: () {
                onPressStartDownload(widget.item.pageUrl);
              },
              child: const Text('다운로드')),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: MediaQuery.of(context).size.width - 40,
          child: OutlinedButton(
              onPressed: () {
                if (Platform.isAndroid || Platform.isIOS) {
                  launchURL(context, widget.item.pageUrl);
                } else {
                  launchURLtoBrowser(context, widget.item.pageUrl);
                }
              },
              child: const Text('웹에서 열기')),
        ),
        const SizedBox(height: 20),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: FutureBuilder(
            future: items,
            builder: (context, AsyncSnapshot<ConLists> snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                    child: GridView.builder(
                  itemBuilder: (context, position) {
                    return img(context, snapshot.data!, position);
                  },
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data!.arcacon.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 100,
                    mainAxisSpacing: 7, //수평 Padding
                    crossAxisSpacing: 7, //수직 Padding
                    mainAxisExtent: 100,
                    //childAspectRatio: (itemWidth / itemHeight), //item 의 가로 1, 세로 2 의 비율
                  ),
                  shrinkWrap: true,
                ));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const CircularProgressIndicator();
            },
          ),
        )
      ]),
    );
  }
}

Widget img(BuildContext context, ConLists data, int position) {
  // debugPrint(data[position]);
  if (data.arcacon[position].contains('.mp4')) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: const SizedBox(
          width: 100,
          height: 100,
          child: Icon(Icons.play_circle, color: Colors.red, size: 50)),
    );
  } else if (data.arcacon[position].endsWith('.thumbnail.jpg')) {
    var key = UniqueKey().toString();
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: SizedBox(
        width: 100,
        height: 100,
        child: GestureDetector(
          onTap: () {
            navigateToImageDetailPage(
                context, data.arcaconTrueUrl[position], key);
          },
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Hero(
                  tag: key,
                  child: CachedNetworkImage(
                    width: 100,
                    height: 100,
                    imageUrl: data.arcaconTrueUrl[position],
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )),
              const Icon(Icons.play_circle, color: Colors.red, size: 24),
            ],
          ),
        ),
      ),
    );
  } else {
    var key = UniqueKey().toString();
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: SizedBox(
        width: 100,
        height: 100,
        child: GestureDetector(
          onTap: () {
            navigateToImageDetailPage(
                context, data.arcaconTrueUrl[position], key);
          },
          child: Hero(
            tag: key,
            child: CachedNetworkImage(
              width: 100,
              height: 100,
              imageUrl: data.arcaconTrueUrl[position],
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}

void navigateToImageDetailPage(BuildContext context, String url, String tag) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).chain(CurveTween(curve: Curves.easeInOutSine)).animate(animation),
          child: Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            child: DetailScreen(
              url: url,
              tag: tag,
            ),
          ),
        );
      },
    ),
  );
}
