import 'package:flutter/material.dart';
import 'package:starboard/json_models/post.dart';
import 'package:starboard/reddit_api.dart';
import 'package:starboard/view_status.dart';

class PostModel with ChangeNotifier, ViewStatus {
  PostModel(
    this.title,
    this.author,
    this.subreddit,
    this.score,
    this.postHint,
    this.url,
    this.numComments,
    this.permalink,
    this.thumbnail,
  );

  String title;
  String author;
  String subreddit;
  int score;
  String postHint;
  String url;
  int numComments;
  String permalink;
  String thumbnail;

  List<Comment> comments;

  void fetchComments() async {
    // Load the comments only once
    if (isLoading() || comments != null) {
      return;
    }
    notifyLoading();

    try {
      var jsonModel = await fetchPostComments(permalink);
      comments =
          jsonModel.data.children.map((e) => _mapJsonToComment(e)).toList();
      notifySuccess();
    } catch (e) {
      notifyError(e);
    }
  }
}

Comment _mapJsonToComment(CommentJsonModel model) {
  return Comment(
    model.data.author,
    model.data.body,
    model.data.score,
    model.data.replies.map((e) => _mapJsonToComment(e)).toList(),
  );
}

class Comment {
  Comment(
    this.author,
    this.body,
    this.score,
    this.replies,
  );

  String author;
  String body;
  int score;
  List<Comment> replies;
}
