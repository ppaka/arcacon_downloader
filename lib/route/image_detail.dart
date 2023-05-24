import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen(
      {Key? key, required this.url, required this.tag, required this.videoUrl})
      : super(key: key);
  final String url;
  final String tag;
  final String videoUrl;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late VideoPlayerController _videoPlayerController;
  String videoUrl = '';

  @override
  void initState() {
    videoUrl = widget.videoUrl;
    if (widget.url.contains('.mp4')) {
      videoUrl = widget.url;
    }

    if (videoUrl != '') {
      _videoPlayerController = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          _videoPlayerController.setLooping(true);
          _videoPlayerController.play();
          setState(() {});
        });
    }

    super.initState();
  }

  @override
  void dispose() {
    if (videoUrl != '' && _videoPlayerController.value.isInitialized) {
      _videoPlayerController.dispose();
    }
    super.dispose();
  }

  Widget videoOrImage() {
    if (widget.url.contains('.mp4') || widget.videoUrl != '') {
      return _videoPlayerController.value.isInitialized
          ? SizedBox(
              width: 200,
              height: 200,
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              ),
            )
          : Container();
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
