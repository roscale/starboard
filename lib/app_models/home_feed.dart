import 'package:flutter/cupertino.dart';
import 'package:starboard/app_models/post.dart';
import 'package:starboard/view_status.dart';
import 'package:starboard/json_models/post.dart';
import 'package:starboard/reddit_api.dart';

class HomeFeedModel with ChangeNotifier, ViewStatus {
  var posts = <PostModel>[];
  String after;

  void fetchMorePosts() async {
    if (isLoading()) {
      return;
    }
    notifyLoading();

    try {
      var jsonModel = await fetchHomeFeed(after);
      posts.addAll(jsonModel.data.children.map((e) => PostModel(
            e.data.title,
            e.data.author,
            e.data.subreddit,
            e.data.ups,
            e.data.post_hint,
            e.data.url,
            e.data.num_comments,
            e.data.permalink,
            e.data.thumbnail,
          )));
      after = jsonModel.data.after;
      notifySuccess();
    } catch (e) {
      notifyError(e);
    }
  }
}

