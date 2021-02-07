import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:starboard/small_screens/video_player_controls.dart';
import 'package:video_player/video_player.dart';

class RedditVideoPlayer extends StatefulWidget {
  final String url;
  final int width;
  final int height;
  final Submission post; // video is fullscreen if post is provided
  final VideoPlayerController controller;
  final bool fullscreen;

  RedditVideoPlayer(
      {Key key,
      @required this.post,
      @required this.width,
      @required this.height,
      this.url,
      this.controller,
      this.fullscreen = false})
      : super(key: key);

  @override
  _RedditVideoPlayerState createState() => _RedditVideoPlayerState();
}

class _RedditVideoPlayerState extends State<RedditVideoPlayer> {
  VideoPlayerController _controller;

  double opacity = 0.0;

  void updateView() => setState(() {});

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller;
      _controller.addListener(() => updateView);
    } else {
      // TODO: can we cache the part of the video that was downloaded?
      _controller = VideoPlayerController.network(widget.url);
      _controller.addListener(() => setState(() {}));
      _controller.setLooping(true);
      _controller.initialize().then((_) => setState(() {}));
      _controller.play();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      // Don't dispose controller if it's passed by another video
      _controller.removeListener(updateView);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget scaffold = Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: Hero(
              tag: widget.post,
              child: AspectRatio(
                aspectRatio: widget.width / widget.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          VideoPlayerControlsOverlay(
            controller: _controller,
            post: widget.post,
            fullscreen: widget.fullscreen,
          ),
        ],
      ),
    );
    if (!widget.fullscreen) {
      scaffold = AspectRatio(
        aspectRatio: widget.width / widget.height,
        child: scaffold,
      );
    }
    return scaffold;
  }
}
