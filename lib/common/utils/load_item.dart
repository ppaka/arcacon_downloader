import 'package:arcacon_downloader/common/models/preview_arcacon.dart';
import 'package:arcacon_downloader/common/utility/string_converter.dart';
import 'package:arcacon_downloader/screen/arcacon_list.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

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
