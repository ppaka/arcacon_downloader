import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

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

class ConPage extends StatelessWidget {
  ConPage({Key? key, PreviewArcaconItem? item}) : super(key: key) {
    this.item = item!;
  }

  late final PreviewArcaconItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Column(children: [
        Row(
          children: [
            if (item.imageUrl.endsWith('mp4'))
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
                        imageUrl: item.imageUrl,
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
                    item.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.clip,
                  ),
                  width: MediaQuery.of(context).size.width - 40 - 100,
                ),
                SizedBox(
                  child: Text(
                    item.maker,
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
                onPressStartDownload(item.pageUrl);
              },
              child: const Text('다운로드')),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width - 40,
          child: OutlinedButton(
              onPressed: () {
                _launchURL(context, item.pageUrl);
              },
              child: const Text('웹에서 열기')),
        ),
      ]),
    );
  }
}
