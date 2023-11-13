import 'dart:io';

import 'package:arcacon_downloader/common/models/aracon_url.dart';
import 'package:arcacon_downloader/common/models/preview_arcacon.dart';
import 'package:arcacon_downloader/common/utility/custom_tab.dart';
import 'package:arcacon_downloader/common/utility/string_converter.dart';
import 'package:arcacon_downloader/common/utils/onpress_download.dart';
import 'package:arcacon_downloader/common/utils/push_detail_arcacon.dart';
import 'package:arcacon_downloader/common/widget/detail_img.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

late Future<List<ArcaconUrl>> items;

// ignore: must_be_immutable
class ConPage extends StatefulWidget {
  ConPage({Key? key, PreviewArcaconItem? item}) : super(key: key) {
    this.item = item!;
  }

  late PreviewArcaconItem item;

  @override
  State<ConPage> createState() => _ConPageState();
}

class _ConPageState extends State<ConPage> {
  Future<List<ArcaconUrl>> getCons(String url) async {
    var client = http.Client();
    List<ArcaconUrl> lists = [];

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

    dom.Element? maker = document.querySelector(
        'body > div.root-container > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-head > div.info-row.clearfix > div.member-info');

    var makerText = maker!.outerHtml.split('\n')[1];

    if (makerText.contains('[email&nbsp;protected]')) {
      makerText = convertEncodedTitleForList(makerText);
    }

    makerText = makerText.trim();
    var makerInvalidChar = RegExp(r'[\/:*?"<>|]');
    if (makerInvalidChar.hasMatch(makerText)) {
      makerText = makerText.replaceAll(makerInvalidChar, '');
    }

    widget.item.title = titleText;
    widget.item.maker = makerText;
    debugPrint(titleText);
    debugPrint(makerText);

    dom.Element links = document.querySelector(
        'body > div > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-body > div')!;

    for (var element in links.children) {
      if (element.toString().startsWith('<div')) {
        break;
      }
      var newItem = ArcaconUrl();
      // poster가 있는 경우 -> 비디오
      if (element.attributes['poster'].toString() != "null") {
        var url = 'https:${element.attributes['poster']}';
        var convertedUrl = url.replaceRange(url.indexOf('?'), url.length, '');
        var videoUrl = 'https:${element.attributes['data-src']}';
        var convertedVideoUrl =
            videoUrl.replaceRange(videoUrl.indexOf('?'), videoUrl.length, '');

        newItem.imageUrl = url;
        newItem.trueImageUrl = convertedUrl;
        newItem.videoUrl = videoUrl;
        newItem.trueVideoUrl = convertedVideoUrl;

        lists.add(newItem);
        continue;
      }
      // src만 있는 경우 -> 일반 이미지
      if (element.attributes['src'].toString() != "null") {
        var url = 'https:${element.attributes['src']}';
        var convertedUrl = url.replaceRange(url.indexOf('?'), url.length, '');

        newItem.imageUrl = url;
        newItem.trueImageUrl = convertedUrl;

        lists.add(newItem);
        continue;
      }
    }
    return lists;
  }

  @override
  void initState() {
    items = getCons(widget.item.pageUrl);
    items.then(
      (value) {
        setState(() {});
      },
    );
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
      body: Column(
        children: [
          Row(
            children: [
              // 아이콘이 mp4일 때
              widget.item.imageUrl.contains('.mp4')
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          navigateToImageDetailPage(
                            context,
                            widget.item.imageUrl,
                            key,
                            null,
                          );
                        },
                        child: Hero(
                          tag: key,
                          child: const SizedBox(
                            width: 100,
                            height: 100,
                            child: Icon(
                              Icons.play_circle,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          navigateToImageDetailPage(
                            context,
                            widget.item.imageUrl,
                            key,
                            null,
                          );
                        },
                        child: Hero(
                          tag: key,
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: CachedNetworkImage(
                              imageUrl: widget.item.imageUrl,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) {
                                return CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                );
                              },
                              errorWidget: (context, url, error) {
                                return const Icon(Icons.error);
                              },
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40 - 100,
                    child: Text(
                      widget.item.maker,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
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
                onPressStartDownload(widget.item.pageUrl, null);
              },
              child: const Text('모두 다운로드'),
            ),
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
              child: const Text('웹에서 열기'),
            ),
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
              builder: (context, AsyncSnapshot<List<ArcaconUrl>> snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: GridView.builder(
                      itemBuilder: (context, position) {
                        return ArcaconDetailImage(
                            context: context,
                            data: snapshot.data!,
                            position: position,
                            pageUrl: widget.item.pageUrl);
                      },
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 100,
                        mainAxisSpacing: 1, //수평 Padding
                        crossAxisSpacing: 1, //수직 Padding
                        mainAxisExtent: 100,
                        //childAspectRatio: (itemWidth / itemHeight), //item 의 가로 1, 세로 2 의 비율
                      ),
                      shrinkWrap: true,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const CircularProgressIndicator();
              },
            ),
          )
        ],
      ),
    );
  }
}