import 'package:arcacon_downloader/common/models/arcacon_url.dart';
import 'package:arcacon_downloader/common/utils/onpress_download.dart';
import 'package:arcacon_downloader/common/utils/push_detail_arcacon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ArcaconDetailImage extends StatelessWidget {
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
  @override
  Widget build(BuildContext context) {
    var margin = const EdgeInsets.fromLTRB(5, 5, 5, 5);
    if (data[position].imageUrl == '') {
      return Container(
        margin: margin,
        child: SizedBox(
          width: 100,
          height: 100,
          child: GestureDetector(
            onLongPress: () {
              showDialog<String>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("길게 눌러 다운로드"),
                    content: const Text('이 아카콘을 다운로드 하실껀가요?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('취소'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text('다운로드'),
                        onPressed: () {
                          Navigator.pop(context);
                          onPressStartDownload(pageUrl, position);
                        },
                      ),
                    ],
                  );
                },
              );
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
              showDialog<String>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("길게 눌러 다운로드"),
                    content: const Text('이 아카콘을 다운로드 하실껀가요?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('취소'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text('다운로드'),
                        onPressed: () {
                          Navigator.pop(context);
                          onPressStartDownload(pageUrl, position);
                        },
                      ),
                    ],
                  );
                },
              );
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
              showDialog<String>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("길게 눌러 다운로드"),
                    content: const Text('이 아카콘을 다운로드 하실껀가요?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('취소'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text('다운로드'),
                        onPressed: () {
                          Navigator.pop(context);
                          onPressStartDownload(pageUrl, position);
                        },
                      ),
                    ],
                  );
                },
              );
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
              showDialog<String>(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("길게 눌러 다운로드"),
                    content: const Text('이 아카콘을 다운로드 하실껀가요?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('취소'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: const Text('다운로드'),
                        onPressed: () {
                          Navigator.pop(context);
                          onPressStartDownload(pageUrl, position);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Hero(
              tag: key,
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                width: 100,
                height: 100,
                imageUrl: data[position].imageUrl,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
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
