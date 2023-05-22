import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key, required this.url, required this.tag})
      : super(key: key);
  final String url;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      constrained: true,
      boundaryMargin: const EdgeInsets.all(-50),
      minScale: 1,
      maxScale: 20,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Color.fromARGB((255 * 0.8).floor(), 0, 0, 0),
          child: AbsorbPointer(
            child: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Hero(
                  tag: tag,
                  child: CachedNetworkImage(
                    imageUrl: url,
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
        ),
      ),
    );
  }
}
