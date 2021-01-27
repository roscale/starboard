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
                  child: CachedNetworkImage(
                    imageUrl: post.preview[0].source.url.toString(),
                    placeholder: (_context, _) =>
                        Center(child: CircularProgressIndicator()),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          ImageViewer(post.preview[0].source.url.toString())));
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
          SizedBox(width: 40),
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
          SizedBox(width: 40),
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
          print("NO");
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        var commentWidgets = post.comments.comments.map((o) {
          var comment = o as Comment;
          return Card(child: Text(comment.body));
        }).toList();

        return Padding(
          padding: EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: commentWidgets,
          ),
        );
      },
    );
  }
}
