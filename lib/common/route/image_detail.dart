import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.url,
    required this.tag,
    required this.videoUrl,
  });
  final String url;
  final String tag;
  final String videoUrl;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late VideoPlayerController _videoPlayerController;
  late final Player player = Player();
  late final controller = VideoController(player,
      configuration:
          const VideoControllerConfiguration(enableHardwareAcceleration: true));
  String videoUrl = '';

  @override
  void initState() {
    videoUrl = widget.videoUrl;
    if (widget.url.contains('.mp4')) {
      videoUrl = widget.url;
    }

    if (videoUrl != '') {
      if (Platform.isAndroid) {
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(videoUrl))
              ..initialize().then(
                (_) {
                  _videoPlayerController.setLooping(true);
                  _videoPlayerController.play();
                  setState(() {});
                },
              );
      } else {
        final playable = Media(videoUrl);
        player.setPlaylistMode(PlaylistMode.single);
        player.setSubtitleTrack(SubtitleTrack.no());
        player.open(playable);
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    if (videoUrl != '') {
      if (Platform.isAndroid) {
        if (_videoPlayerController.value.isInitialized) {
          _videoPlayerController.dispose();
        }
      } else {
        player.dispose();
      }
    }
    super.dispose();
  }

  Widget videoOrImage() {
    if (widget.url.contains('.mp4') || widget.videoUrl != '') {
      if (Platform.isAndroid) {
        return _videoPlayerController.value.isInitialized
            ? SizedBox(
                width: 200,
                height: 200,
                child: AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
                ),
              )
            : Container(
                color: Colors.black,
                width: 200,
                height: 200,
              );
      } else {
        final video = Video(
          controller: controller,
          controls: NoVideoControls,
          filterQuality: FilterQuality.none,
          wakelock: false,
        );

        return SingleChildScrollView(
          child: SizedBox(
            width: 200,
            height: 200,
            child: video,
          ),
        );
      }
    }

    return CachedNetworkImage(
      fit: BoxFit.contain,
      imageUrl: widget.url,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return CircularProgressIndicator(
          value: downloadProgress.progress,
        );
      },
      errorWidget: (context, url, error) {
        return const Icon(Icons.error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      panEnabled: true,
      scaleEnabled: true,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(0),
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
          color: Color.fromARGB((255 * 0.85).floor(), 0, 0, 0),
          child: AbsorbPointer(
            child: Center(
              child: Hero(tag: widget.tag, child: videoOrImage()),
            ),
          ),
        ),
      ),
    );
  }
}
