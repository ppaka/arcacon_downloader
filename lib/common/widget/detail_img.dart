import 'package:arcacon_downloader/common/models/arcacon_url.dart';
import 'package:arcacon_downloader/common/utils/clipboard.dart';
import 'package:arcacon_downloader/common/utils/onpress_download.dart';
import 'package:arcacon_downloader/common/utils/push_detail_arcacon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArcaconDetailImage extends ConsumerWidget {
  const ArcaconDetailImage(
      {super.key,
      required this.context,
      required this.data,
      required this.position,
      required this.pageUrl});

  final BuildContext context;
  final List<ArcaconUrl> data;
  final int position;
  final String pageUrl;

  void _onLongPress(WidgetRef ref) {
    showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("단일 선택 메뉴"),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('링크 주소 복사'),
              onPressed: () {
                Navigator.pop(context);
                if (data[position].videoUrl.isNotEmpty) {
                  copyToClipboard(data[position].videoUrl);
                } else {
                  copyToClipboard(data[position].imageUrl);
                }
              },
            ),
            TextButton(
              child: const Text('다운로드'),
              onPressed: () {
                Navigator.pop(context);
                onPressStartDownload(ref, pageUrl, position, () {});
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var margin = const EdgeInsets.fromLTRB(5, 5, 5, 5);
    if (data[position].imageUrl.isEmpty) {
      return Container(
        margin: margin,
        child: SizedBox(
          width: 100,
          height: 100,
          child: GestureDetector(
            onLongPress: () {
              _onLongPress(ref);
            },
            onSecondaryTapUp: (details) {
              _onLongPress(ref);
            },
            child: const Icon(Icons.play_circle, color: Colors.red, size: 50),
          ),
        ),
      );
    } else if (data[position].imageUrl.contains('.thumbnail.')) {
      var key = UniqueKey().toString();
      return Container(
        margin: margin,
        child: SizedBox(
          width: 100,
          height: 100,
          child: GestureDetector(
            onTap: () {
              navigateToImageDetailPage(context, data[position].imageUrl, key,
                  data[position].videoUrl);
            },
            onLongPress: () {
              _onLongPress(ref);
            },
            onSecondaryTapUp: (details) {
              _onLongPress(ref);
            },
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Hero(
                  tag: key,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    imageUrl: data[position].imageUrl,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 3, 3),
                  child: const Icon(Icons.play_circle,
                      color: Colors.redAccent, size: 24),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (data[position].imageUrl.contains('.mp4')) {
      var key = UniqueKey().toString();
      return Container(
        margin: margin,
        child: SizedBox(
          width: 100,
          height: 100,
          child: GestureDetector(
            onTap: () {
              navigateToImageDetailPage(
                  context, data[position].imageUrl, key, null);
            },
            onLongPress: () {
              _onLongPress(ref);
            },
            onSecondaryTapUp: (details) {
              _onLongPress(ref);
            },
            child: Hero(
              tag: key,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.white,
                child: const Material(
                  type: MaterialType.transparency,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error,
                        color: Colors.black,
                      ),
                      Text(
                        'mp4',
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      var key = UniqueKey().toString();
      return Container(
        margin: margin,
        child: SizedBox(
          width: 100,
          height: 100,
          child: GestureDetector(
            onTap: () {
              navigateToImageDetailPage(
                  context, data[position].imageUrl, key, null);
            },
            onLongPress: () {
              _onLongPress(ref);
            },
            onSecondaryTapUp: (details) {
              _onLongPress(ref);
            },
            child: Hero(
              tag: key,
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                imageUrl: data[position].imageUrl,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(
                  value: downloadProgress.progress,
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.white,
                    child: const Material(
                      type: MaterialType.transparency,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }
  }
}
