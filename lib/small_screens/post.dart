import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:starboard/app_models/post.dart';
import 'package:starboard/util.dart';

class Post extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PostModel post = ModalRoute.of(context).settings.arguments;
    assert(post != null);
    post.fetchComments();

    return ChangeNotifierProvider.value(
      value: post,
      child: Builder(
        builder: (context) {
          PostModel post = Provider.of<PostModel>(context);
          return Scaffold(
            appBar: AppBar(),
            body: ListView(
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
                if (post.postHint == "image")
                  CachedNetworkImage(
                      imageUrl: post.url,
                      placeholder: (_context, _) =>
                          Center(child: CircularProgressIndicator())),
                _buildActionButtons(context, post),
                _buildComments(context, post),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(PostModel post) {
    return Row(
      children: [
        Icon(Icons.public, color: Colors.blue),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("r/${post.subreddit}"),
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

  Widget _buildActionButtons(BuildContext context, PostModel post) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.keyboard_arrow_up),
                iconSize: 26,
                color: Colors.grey,
                splashColor: Colors.deepOrange,
                padding: EdgeInsets.all(0),
                constraints: BoxConstraints(),
                splashRadius: 15,
                onPressed: () {
                  Fluttertoast.showToast(msg: "Unimplemented");
                },
              ),
              Text(
                formatBigNumber(post.score),
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_down),
                iconSize: 26,
                color: Colors.grey,
                splashColor: Colors.blue,
                padding: EdgeInsets.all(0),
                constraints: BoxConstraints(),
                splashRadius: 15,
                onPressed: () {
                  Fluttertoast.showToast(msg: "Unimplemented");
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
              Share.share("https://reddit.com${post.permalink}");
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

  Widget _buildComments(BuildContext context, PostModel post) {
    if (post.hasError()) {
      return Text("Error loading comments: ${post.error}");
    }
    if (post.isLoading()) {
      return CircularProgressIndicator();
    }
    var commentWidgets = <Widget>[];
    post.comments.forEach((comment) {
      if (comment.body == null) {
        return;
      }
      commentWidgets.add(Card(child: Text(comment.body)));
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: commentWidgets,
    );
  }
}
