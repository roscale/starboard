import 'package:cached_network_image/cached_network_image.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final Submission post;
  final String url;

  ImageViewer(this.post, this.url);

  @override
  Widget build(BuildContext context) {
    print("URLLLLLL: $url");
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "r/${post.subreddit.displayName} • u/${post.author}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(post.title)
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: InteractiveViewer(
          maxScale: 5,
          child: Hero(
            tag: url,
            child: CachedNetworkImage(
              imageUrl: url,
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
    );
  }
}
