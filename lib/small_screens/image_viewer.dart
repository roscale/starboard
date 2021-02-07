import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatefulWidget {
  final Submission post;
  final String url;

  ImageViewer(this.post, this.url);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  double opacity = 1.0;
  CancelableOperation<void> showDelay;

  @override
  void initState() {
    super.initState();
    showControls();
  }

  @override
  void dispose() {
    showDelay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (opacity == 0.0) {
                showControls();
              } else {
                hideControls();
              }
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: InteractiveViewer(
                maxScale: 5,
                child: Hero(
                  tag: widget.url,
                  child: CachedNetworkImage(
                    imageUrl: widget.url,
                    progressIndicatorBuilder: (_, __, progress) {
                      if (progress.progress == null) {
                        return Container();
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.progress,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
    setState(() => opacity = 0.0);
    showDelay?.cancel();
  }
}
