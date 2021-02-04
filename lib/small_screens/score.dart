import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:starboard/app_models/posts.dart';
import 'package:starboard/util.dart';
import 'package:provider/provider.dart';

class Score extends StatelessWidget {
  final Submission submission;
  
  Score(this.submission);

  @override
  Widget build(BuildContext context) {
    var localState = context.watch<PostLocalState>();

    // Prioritize local state if the user voted
    VoteState vote;
    if (localState.vote != null) {
      vote = localState.vote;
    } else {
      vote = submission.vote;
    }

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.keyboard_arrow_up),
          iconSize: 26,
          color: vote == VoteState.upvoted ? Colors.deepOrange : Colors.grey,
          splashColor: Colors.deepOrange,
          padding: EdgeInsets.all(0),
          constraints: BoxConstraints(),
          splashRadius: 15,
          onPressed: () {
            // FIXME: Spamming voting buttons leads to inconsistent local state
            if (vote == VoteState.upvoted) {
              localState.clearVote();
              submission.clearVote();
            } else {
              localState.upvote();
              submission.upvote();
            }
          },
        ),
        Text(
          formatBigNumber(submission.score),
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        IconButton(
          icon: Icon(Icons.keyboard_arrow_down),
          iconSize: 26,
          color: vote == VoteState.downvoted ? Colors.blue : Colors.grey,
          splashColor: Colors.blue,
          padding: EdgeInsets.all(0),
          constraints: BoxConstraints(),
          splashRadius: 15,
          onPressed: () {
            if (vote == VoteState.downvoted) {
              localState.clearVote();
              submission.clearVote();
            } else {
              localState.downvote();
              submission.downvote();
            }
          },
        ),
      ],
    );
  }
}
