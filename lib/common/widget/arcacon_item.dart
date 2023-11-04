import 'package:arcacon_downloader/common/models/preview_arcacon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:arcacon_downloader/common/route/con_page.dart';
import 'package:flutter/material.dart';

class ArcaconItem extends StatelessWidget {
  const ArcaconItem(
      {super.key, required this.snapshot, required this.position});

  final AsyncSnapshot<List<PreviewArcaconItem>> snapshot;
  final int position;

  @override
  Widget build(BuildContext context) {
    return Card(
      borderOnForeground: false,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
            if (snapshot.data![position].imageUrl.contains('mp4'))
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: const SizedBox(
                    width: 100,
                    height: 100,
                    child:
                        Icon(Icons.play_circle, color: Colors.red, size: 50)),
              )
            else
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CachedNetworkImage(
                    imageUrl: snapshot.data![position].imageUrl,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
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
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Text(
                snapshot.data![position].maker,
                style: const TextStyle(fontWeight: FontWeight.normal),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
