import 'package:draw/draw.dart';

String formatBigNumber(int n) {
  var abs = n.abs();
  if (abs < 1000) {
    return "$n";
  }
  if (abs >= 1000 && abs < 100000) {
    return "${(n / 1000).toStringAsFixed(1)}k";
  }
  return "${(n ~/ 1000)}k";
}

// Work around library bug
// https://github.com/draw-dev/DRAW/pull/173
Uri shortLink(Reddit reddit, Submission post) {
  return Uri.parse("${reddit.config.shortUrl}/${post.id}");
}