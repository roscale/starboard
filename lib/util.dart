import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:url_launcher/url_launcher.dart';

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

String formatVideoDuration(Duration duration) {
  return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, "0")}";
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

Widget inkwellOverWidget({@required Widget widget, @required Function onTap}) {
  return Stack(
    children: [
      widget,
      Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
          ),
        ),
      )
    ],
  );
}

Widget markdownRedditText(String text) {
  return MarkdownBody(
    data: HtmlUnescape().convert(text),
    onTapLink: (_text, href, _title) => launch(href),
    styleSheet: MarkdownStyleSheet(
      a: TextStyle(decoration: TextDecoration.underline),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      blockquotePadding: EdgeInsets.only(left: 10, top: 2, bottom: 2),
    ),
  );
}
