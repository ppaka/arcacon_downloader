import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

import '../screen/arcacon_list.dart';
import '../screen/first_page.dart';

void _launchURL(BuildContext context, String url) async {
  try {
    await launch(
      url,
      customTabsOption: CustomTabsOption(
        toolbarColor: Colors.grey[850],
        enableDefaultShare: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
        animation: CustomTabsSystemAnimation.fade(),
        extraCustomTabs: const <String>[
          // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
          'org.mozilla.firefox',
          // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
          'com.microsoft.emmx',
        ],
      ),
      safariVCOption: SafariViewControllerOption(
        preferredBarTintColor: Colors.grey[850],
        preferredControlTintColor: Colors.white,
        barCollapsingEnabled: true,
        entersReaderIfAvailable: false,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
      ),
    );
  } catch (e) {
    // An exception is thrown if browser app is not installed on Android device.
    debugPrint(e.toString());
  }
}

Future<List<String>> getCons(String url) async {
  var client = http.Client();
  List<String> list = <String>[];
  print('작업 시작');

  http.Response response;
  try {
    response = await client.get(Uri.parse(url));
  } catch (ex) {
    debugPrint(ex.toString());
    return list;
  }

  var document = parser.parse(response.body);
  dom.Element? title = document.querySelector(
      'body > div.root-container > div.content-wrapper.clearfix > article > div > div.article-wrapper > div.article-head > div.title-row > div');

  var titleText = title!.outerHtml.split('\n')[1];

  if (titleText.contains('[email&nbsp;protected]')) {
    titleText = convertEncodedTitle(titleText);
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
    if (element.attributes['src'].toString() == "null") {
      continue;
    }
    list.add('https:' + element.attributes['src'].toString());
  }
  return list;
}

late Future<List<String>> items;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Column(children: [
        Row(
          children: [
            if (widget.item.imageUrl.endsWith('mp4'))
              Container(
                child: const SizedBox(
                    width: 100,
                    height: 100,
                    child:
                        Icon(Icons.play_circle, color: Colors.red, size: 50)),
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              )
            else
              Container(
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
                      )),
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0)),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Text(
                    widget.item.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.clip,
                  ),
                  width: MediaQuery.of(context).size.width - 40 - 100,
                ),
                SizedBox(
                  child: Text(
                    widget.item.maker,
                    style: const TextStyle(fontSize: 15),
                  ),
                  width: MediaQuery.of(context).size.width - 40 - 100,
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
        SizedBox(
          width: MediaQuery.of(context).size.width - 40,
          child: OutlinedButton(
              onPressed: () {
                _launchURL(context, widget.item.pageUrl);
              },
              child: const Text('웹에서 열기')),
        ),
        const SizedBox(height: 20),
        FutureBuilder(
          future: items,
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.hasData) {
              return Expanded(
                  child: GridView.builder(
                itemBuilder: (context, position) {
                  return img(snapshot.data!, position);
                },
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
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
      ]),
    );
  }
}

Widget img(List<String> data, int position) {
  print('작업 2');
  print(data[position]);

  if (data[position].endsWith('mp4')) {
    return Container(
      child: const SizedBox(
          width: 100,
          height: 100,
          child: Icon(Icons.play_circle, color: Colors.red, size: 50)),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
    );
  } else {
    return Container(
      child: SizedBox(
        width: 100,
        height: 100,
        child: CachedNetworkImage(
          imageUrl: data[position],
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
    );
  }
}
