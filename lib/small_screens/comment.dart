import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:starboard/util.dart';

class LinearComment {
  int indentation;
  dynamic comment;

  LinearComment(this.indentation, this.comment);
}

class MyComment extends StatefulWidget {
  final Submission submission;
  final dynamic comment;

  MyComment(this.submission, this.comment);

  @override
  _MyCommentState createState() => _MyCommentState();

  static void linearizeComments(
      CommentForest commentForest, List<LinearComment> dest,
      {level = 0}) {
    for (var c in commentForest.comments) {
      dest.add(LinearComment(level, c));
      if (c is Comment && c.replies != null) {
        linearizeComments(c.replies, dest, level: level + 1);
      }
    }
  }

  static Widget indentComment(Widget comment, int indentation) {
    for (var i = 0; i < indentation; i++) {
      comment = Padding(
        padding: EdgeInsets.only(left: 15),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.grey.shade800,
                width: 1.5,
              ),
            ),
          ),
          child: comment,
        ),
      );
    }
    return comment;
  }
}

class _MyCommentState extends State<MyComment> {
  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;

    if (comment is MoreComments) {
      return Row(
        children: [
          Padding(padding: EdgeInsets.only(left: 5)),
          TextButton(
              child: Text("${comment.count} more replies"), onPressed: () {}),
        ],
      );
    } else if (comment is Comment) {
      return Padding(
        padding: const EdgeInsets.only(left: 15, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(
                comment.author,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: comment.author == widget.submission.author
                      ? Colors.blue
                      : Colors.white,
                ),
              ),
              Text(
                " • ${formatDuration(DateTime.now().difference(comment.createdUtc))}",
                style: TextStyle(color: Colors.grey),
              )
            ]),
            Padding(padding: EdgeInsets.only(top: 5)),
            Padding(
              // Avoid scrollbar covering the text
              padding: const EdgeInsets.only(right: 10),
              child: markdownRedditText(comment.body),
            ),
            Padding(padding: EdgeInsets.only(top: 5)),
            _buildActionButtons(),
          ],
        ),
      );
    }
    assert(false, "Should never get here");
    return Container();
  }

  Widget _buildActionButtons() {
    final comment = widget.comment as Comment;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(Icons.reply),
          color: Colors.grey,
          padding: EdgeInsets.all(4),
          constraints: BoxConstraints(),
          iconSize: 20,
          splashRadius: 15,
          onPressed: () {},
        ),
        Padding(padding: EdgeInsets.only(left: 20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_up),
                  iconSize: 26,
                  color: comment.vote == VoteState.upvoted
                      ? Colors.deepOrange
                      : Colors.grey,
                  splashColor: Colors.deepOrange,
                  padding: EdgeInsets.all(0),
                  constraints: BoxConstraints(),
                  splashRadius: 15,
                  onPressed: () async {
                    if (comment.vote == VoteState.upvoted) {
                      await comment.clearVote();
                    } else {
                      await comment.upvote();
                    }
                  },
                ),
                Text(
                  formatBigNumber(comment.score),
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_down),
                  iconSize: 26,
                  color: comment.vote == VoteState.downvoted
                      ? Colors.blue
                      : Colors.grey,
                  splashColor: Colors.blue,
                  padding: EdgeInsets.all(0),
                  constraints: BoxConstraints(),
                  splashRadius: 15,
                  onPressed: () async {
                    if (comment.vote == VoteState.downvoted) {
                      await comment.clearVote();
                    } else {
                      await comment.downvote();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        Padding(padding: EdgeInsets.only(right: 8))
      ],
    );
  }
}
