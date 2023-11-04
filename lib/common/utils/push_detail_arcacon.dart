import 'package:arcacon_downloader/common/route/image_detail.dart';
import 'package:flutter/material.dart';

void navigateToImageDetailPage(
    BuildContext context, String url, String tag, String? videoUrl) {
  print("그냥 url: $url");
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
            child: DetailScreen(url: url, tag: tag, videoUrl: videoUrl ?? ''),
          ),
        );
      },
    ),
  );
}
