import 'package:async/async.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:starboard/small_screens/reddit_video_player.dart';
import 'package:starboard/util.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final Submission post;
  final bool fullscreen;

  const VideoPlayerControlsOverlay({
    Key key,
    @required this.controller,
    @required this.post,
    @required this.fullscreen,
  }) : super(key: key);

  @override
  _VideoPlayerControlsOverlayState createState() =>
      _VideoPlayerControlsOverlayState();
}

class _VideoPlayerControlsOverlayState
    extends State<VideoPlayerControlsOverlay> {
  double opacity = 0.0;
  CancelableOperation<void> showDelay;

  @override
  void dispose() {
    showDelay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () async {
            if (opacity == 0.0) {
              showControls();
            } else {
              hideControls();
            }
          },
          child: AbsorbPointer(
            absorbing: opacity == 0.0,
            child: AnimatedOpacity(
              opacity: opacity,
              duration: Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Stack(
                  children: [
                    Center(
                      child: IconButton(
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        iconSize: 50,
                        // splashRadius: 50,
                        onPressed: () {
                          if (controller.value.isPlaying) {
                            controller.pause();
                            showControls();
                          } else {
                            controller.play();
                            hideControls();
                          }
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Builder(
                        builder: (context) {
                          var duration = controller.value.duration;
                          var progress;
                          if (duration == null) {
                            progress = 0.0;
                          } else {
                            progress = controller.value.position.inSeconds /
                                controller.value.duration.inSeconds;
                          }
                          progress = progress.clamp(0.0, 1.0);

                          return Row(
                            children: [
                              IconButton(
                                  icon: Icon(controller.value.volume != 0.0
                                      ? Icons.volume_up
                                      : Icons.volume_off),
                                  onPressed: () {}),
                              Text(formatVideoDuration(
                                controller.value.position,
                              )),
                              Expanded(
                                child: Slider(
                                  value: progress,
                                  inactiveColor: Colors.white,
                                  onChanged: (value) {
                                    showControls();
                                    var position =
                                        controller.value.duration * value;
                                    controller.seekTo(position);
                                  },
                                ),
                              ),
                              Text(formatVideoDuration(
                                controller.value.duration ?? Duration(),
                              )),
                              if (!widget.fullscreen)
                                IconButton(
                                  icon: Icon(Icons.fullscreen),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => RedditVideoPlayer(
                                          post: widget.post,
                                          width: controller.value.size.width
                                              .toInt(),
                                          height: controller.value.size.height
                                              .toInt(),
                                          controller: controller,
                                          fullscreen: true,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              else
                                IconButton(
                                  icon: Icon(Icons.fullscreen_exit),
                                  onPressed: () => Navigator.of(context).pop(),
                                )
                            ],
                          );
                        },
                      ),
                    ),
                    if (widget.fullscreen)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: opacity == 0.0
                              ? SizedBox()
                              : AppBar(
                                  backgroundColor: Colors.black45,
                                  titleSpacing: 0,
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "r/${widget.post.subreddit.displayName} • u/${widget.post.author}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(widget.post.title)
                                    ],
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showControls() async {
    setState(() {
      opacity = 1.0;
    });
    await showDelay?.cancel();
    showDelay = CancelableOperation.fromFuture(
      Future.delayed(Duration(seconds: 3)),
    )..value.then((_) => setState(() => opacity = 0.0));
  }

  Future<void> hideControls() async {
    setState(() {
      opacity = 0.0;
    });
    showDelay?.cancel();
  }
}
