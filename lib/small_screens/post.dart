import 'package:cached_network_image/cached_network_image.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:starboard/small_screens/image_viewer.dart';
import 'package:starboard/util.dart';

class Post extends StatefulWidget {
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  Submission post;
  Future commentsRefreshed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    post = ModalRoute.of(context).settings.arguments;
    assert(post != null);
    if (post.comments == null) {
      commentsRefreshed = post.refreshComments();
    } else {
      commentsRefreshed = Future.value(post.comments);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).cardColor,
        onRefresh: () async {
          await post.refresh();
          post.refreshComments();
          setState(() {});
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(post),
                  Divider(),
                  Text(
                    post.title,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            if (!post.isSelf)
              InkWell(
                child: Hero(
                  tag: post.preview[0].source.url.toString(),
                  child: AspectRatio(
                    aspectRatio: post.preview[0].source.width /
                        post.preview[0].source.height,
                    child: CachedNetworkImage(
                      imageUrl: post.preview[0].source.url.toString(),
                      placeholder: (_context, _) =>
                          Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ImageViewer(
                          post, post.preview[0].source.url.toString())));
                },
              ),
            _buildActionButtons(context, post),
            _buildComments(context, post),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Submission post) {
    return Row(
      children: [
        Icon(Icons.public, color: Colors.blue),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("r/${post.subreddit.displayName}"),
            SizedBox(height: 2),
            Text(
              "Posted by u/${post.author}",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Submission post) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.keyboard_arrow_up),
                iconSize: 26,
                color: post.vote == VoteState.upvoted
                    ? Colors.deepOrange
                    : Colors.grey,
                splashColor: Colors.deepOrange,
                padding: EdgeInsets.all(0),
                constraints: BoxConstraints(),
                splashRadius: 15,
                onPressed: () async {
                  if (post.vote == VoteState.upvoted) {
                    await post.clearVote();
                  } else {
                    await post.upvote();
                  }
                },
              ),
              Text(
                formatBigNumber(post.score),
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_down),
                iconSize: 26,
                color: post.vote == VoteState.downvoted
                    ? Colors.blue
                    : Colors.grey,
                splashColor: Colors.blue,
                padding: EdgeInsets.all(0),
                constraints: BoxConstraints(),
                splashRadius: 15,
                onPressed: () async {
                  if (post.vote == VoteState.downvoted) {
                    await post.clearVote();
                  } else {
                    await post.downvote();
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  Icons.comment,
                  size: 16,
                  color: Colors.grey,
                ),
                SizedBox(width: 5),
                Text(
                  "${formatBigNumber(post.numComments)}",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Share.share(post.url.toString());
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.share,
                    size: 16,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Share",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComments(BuildContext context, Submission post) {
    return FutureBuilder(
      future: commentsRefreshed,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        var commentWidgets = _buildCommentForest(post.comments);

        if (commentWidgets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Text(
                "No comments\n¯\\_(ツ)_/¯",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: commentWidgets,
            ),
          );
        }
      },
    );
  }

  List<Widget> _buildCommentForest(CommentForest commentForest,
      {topLevel = true}) {
    return commentForest.comments.map((c) {
      if (c is MoreComments) {
        return TextButton(
            onPressed: () {}, child: Text("${c.count} more replies"));
      } else if (c is Comment) {
        return Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(
                  Icons.account_circle,
                  color: Colors.orange,
                ),
                Padding(padding: EdgeInsets.only(left: 5)),
                Text(
                  c.author,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  " • ${formatDuration(DateTime.now().difference(c.createdUtc))}",
                  style: TextStyle(color: Colors.grey),
                )
              ]),
              Padding(padding: EdgeInsets.only(top: 5)),

              Text(c.body),
              Padding(padding: EdgeInsets.only(top: 5)),
              _buildCommentActionButtons(c),

              if (c.replies != null && c.replies.length > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.grey.shade800,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildCommentForest(c.replies),
                        ),
                      ),
                    ),
                  ],
                ),
              if (c != commentForest.comments.last)
                Padding(padding: EdgeInsets.only(top: 10)),
            ],
          ),
        );
      }
    }).toList();
  }

  Widget _buildCommentActionButtons(Comment c) {
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
                  color: c.vote == VoteState.upvoted
                      ? Colors.deepOrange
                      : Colors.grey,
                  splashColor: Colors.deepOrange,
                  padding: EdgeInsets.all(0),
                  constraints: BoxConstraints(),
                  splashRadius: 15,
                  onPressed: () async {
                    if (c.vote == VoteState.upvoted) {
                      await c.clearVote();
                    } else {
                      await c.upvote();
                    }
                  },
                ),
                Text(
                  formatBigNumber(c.score),
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_down),
                  iconSize: 26,
                  color: c.vote == VoteState.downvoted
                      ? Colors.blue
                      : Colors.grey,
                  splashColor: Colors.blue,
                  padding: EdgeInsets.all(0),
                  constraints: BoxConstraints(),
                  splashRadius: 15,
                  onPressed: () async {
                    if (c.vote == VoteState.downvoted) {
                      await c.clearVote();
                    } else {
                      await c.downvote();
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
