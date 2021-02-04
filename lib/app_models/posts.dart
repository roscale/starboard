import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

enum Vote {
  None,
  Upvoted,
  Downvoted,
}

class PostLocalState with ChangeNotifier {
  bool _visited;
  VoteState _vote;

  bool get visited => _visited;
  VoteState get vote => _vote;

  void visit() {
    if (_visited == null || !_visited) {
      _visited = true;
      notifyListeners();
    }
  }

  void upvote() {
    _vote = VoteState.upvoted;
    notifyListeners();
  }

  void downvote() {
    _vote = VoteState.downvoted;
    notifyListeners();
  }

  void clearVote() {
    _vote = VoteState.none;
    notifyListeners();
  }
}

class PostsLocalState {
  Map<String, PostLocalState> posts = {};

  PostLocalState getOrCreate(String id) {
    return posts.putIfAbsent(id, () => PostLocalState());
  }
}
