import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../screen/arcacon_list.dart';

Future<Image> loadThumbnailImage(AsyncSnapshot snapshot, int index) {
  return Future<Image>(() async {
    var thumbnail = await VideoThumbnail.thumbnailData(
      video: snapshot.data![index].imageUrl,
      imageFormat: ImageFormat.PNG,
      maxWidth: 100,
      maxHeight: 100,
      timeMs: 0,
      quality: 100,
    );

    return Image.memory(thumbnail!);
  });
}

Future<VideoPlayerController> loadVideo(AsyncSnapshot snapshot, int index) {
  return Future<VideoPlayerController>(
    () async {
      VideoPlayerController controller = VideoPlayerController.network(
        snapshot.data![index].imageUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      controller.initialize();
      controller.setLooping(true);
      controller.pause();

      //videoControllers[index]!.controller = controller;
      //videoControllers[index]!.isPlaying = true;

      return controller;
    },
  );
}
