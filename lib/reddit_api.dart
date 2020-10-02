import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:starboard/json_models/home_feed.dart';
import 'package:starboard/json_models/post.dart';

const HOME_URL = 'reddit.com';

Future<String> httpGetNoUser(url) async {
  var response = await get(url);
  if (response.statusCode != HttpStatus.ok) {
    return Future.error(response.reasonPhrase);
  } else {
    return response.body;
  }
}

Future<HomeFeedJsonModel> fetchHomeFeed([String after]) async {
  var uri;
  if (after != null) {
    uri = Uri.https(HOME_URL, '/.json', {'after': after});
  } else {
    uri = Uri.https(HOME_URL, '/.json');
  }
  String json = await httpGetNoUser(uri);
  return HomeFeedJsonModel.fromJson(jsonDecode(json));
}

Future<CommentsJsonModel> fetchPostComments(String permalink) async {
  var uri = Uri.https(HOME_URL, '$permalink/.json', {
    'limit': "${100}",
    'depth': "${1}",
  });
  String json = await httpGetNoUser(uri);
  return CommentsJsonModel.fromJson((jsonDecode(json) as List)[1]);
}
