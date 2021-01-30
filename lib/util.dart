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

String formatDuration(Duration duration) {
  if (duration.inSeconds < 60) {
    return "${duration.inSeconds}s";
  }
  if (duration.inMinutes < 60) {
    return "${duration.inMinutes}m";
  }
  if (duration.inHours < 24) {
    return "${duration.inHours}h";
  }
  if (duration.inDays < 7) {
    return "${duration.inDays}d";
  }
  return "${duration.inDays ~/ 7}w";
}