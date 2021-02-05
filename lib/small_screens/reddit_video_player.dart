import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class RedditVideoPlayer extends StatefulWidget {
  final String url;
  final int width;
  final int height;

  RedditVideoPlayer(
      {Key key,
      @required this.url,
      @required this.width,
      @required this.height})
      : super(key: key);

  @override
  _RedditVideoPlayerState createState() => _RedditVideoPlayerState();
}

class _RedditVideoPlayerState extends State<RedditVideoPlayer> {
  VideoPlayerController _controller;

  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _controller.addListener(() => setState(() {}));
    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.width / widget.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          VideoProgressIndicator(_controller, allowScrubbing: true),
        ],
      ),
    );
  }
}
