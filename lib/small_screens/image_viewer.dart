import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String url;

  ImageViewer(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: InteractiveViewer(
        maxScale: 5,
        child: Hero(
          tag: url,
          child: CachedNetworkImage(
            imageUrl: url,
            placeholder: (_context, _) =>
                Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
