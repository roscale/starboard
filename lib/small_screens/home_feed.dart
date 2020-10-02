import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:starboard/app_models/home_feed.dart';
import 'package:starboard/app_models/post.dart';
import 'package:starboard/util.dart';

class HomeFeed extends StatefulWidget {
  @override
  _HomeFeedState createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent - 1000) {
        Provider.of<HomeFeedModel>(context, listen: false).fetchMorePosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Builder(
        builder: (context) {
          var homeFeedModel = Provider.of<HomeFeedModel>(context);
          if (homeFeedModel.hasError()) {
            return Center(
              child: Text("An error has occurred: ${homeFeedModel.error}"),
            );
          }
          return Scrollbar(
            controller: _scrollController,
            child: _buildListView(homeFeedModel.posts),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<PostModel> posts) {
    return ListView.separated(
      separatorBuilder: (context, i) => Divider(height: 0),
      controller: _scrollController,
      itemCount: posts.length + 2,
      itemBuilder: (BuildContext context, int index) {
        if (index < posts.length) {
          return _buildPost(posts[index]);
        } else {
          return ListTile(
            title: Text("-----------------------------"),
            onTap: () {},
          );
        }
      },
    );
  }

  Widget _buildPost(PostModel post) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/comments', arguments: post);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0),
        child: Column(
          children: [
            _buildTitleAndThumbnail(post),
            SizedBox(height: 10),
            Transform.translate(
              offset: Offset(-5, 0),
              child: _buildActionButtons(post),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndThumbnail(PostModel post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "r/${post.subreddit}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 5),
            Container(
              width: post.postHint == "image"
                  ? MediaQuery.of(context).size.width - 120
                  : MediaQuery.of(context).size.width - 30,
              child: Text(
                post.title,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        if (post.postHint == "image")
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: Builder(builder: (context) {
              return CachedNetworkImage(
                fadeInDuration: Duration(milliseconds: 200),
                imageUrl: post.thumbnail,
                width: 85,
                height: 60,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              );
            }),
          )
        else
          Container(),
      ],
    );
  }

  Widget _buildActionButtons(PostModel post) {
    return Row(
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
        InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/comments', arguments: post);
          },
          child: Padding(
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
    );
  }
}