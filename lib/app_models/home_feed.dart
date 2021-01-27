import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:starboard/view_status.dart';

class HomeFeedModel with ChangeNotifier, ViewStatus {
  var posts = <Submission>[];
  String after;

  void fetchMorePosts(Reddit reddit) async {
    if (isLoading()) {
      return;
    }
    notifyLoading();

    try {
      posts.addAll(
          (await reddit.front.best(after: after, limit: 20).toList()).map((
              e) => e as Submission));
      after = posts.last.fullname;
      notifySuccess();
    } catch (e) {
      notifyError(e);
    }
  }
}

