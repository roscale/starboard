import 'package:cached_network_image/cached_network_image.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:starboard/app_models/app_model.dart';
import 'package:starboard/app_models/posts.dart';
import 'package:starboard/small_screens/image_viewer.dart';
import 'package:starboard/small_screens/reddit_video_player.dart';
import 'package:starboard/small_screens/score.dart';
import 'package:starboard/util.dart';
import 'package:url_launcher/url_launcher.dart';

import 'comment.dart';

class Post extends StatefulWidget {
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  Submission post;
  Future commentsRefreshed;
  GlobalKey headerKey = GlobalKey();

  var _scrollController = ScrollController();

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
        child: FutureBuilder(
          future: commentsRefreshed,
          builder: (_, snapshot) {
            // Loading comments
            if (!snapshot.hasData) {
              return ListView(
                children: [
                  Header(key: headerKey, post: post),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            }
            // No comments
            if (post.comments.length == 0) {
              return ListView(
                children: [
                  Header(key: headerKey, post: post),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Text(
                        "No comments\n¯\\_(ツ)_/¯",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              );
            }

            var linearComments = <LinearComment>[];
            MyComment.linearizeComments(post.comments, linearComments);

            return Scrollbar(
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: 1 + linearComments.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Header(key: headerKey, post: post);
                  }
                  var comment =
                      MyComment(post, linearComments[index - 1].comment);
                  return MyComment.indentComment(
                      comment, linearComments[index - 1].indentation);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class Header extends StatefulWidget {
  final Submission post;

  const Header({Key key, this.post}) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var post = widget.post;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSource(post),
              Divider(),
              Text(
                HtmlUnescape().convert(post.title),
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
        Builder(
          builder: (_) {
            if (post.isSelf) {
              if (post.selftext.isEmpty) {
                return Container();
              }
              return Padding(
                padding: EdgeInsets.all(15.0),
                child: markdownRedditText(post.selftext),
              );
            }

            var isLink =
                !post.isRedditMediaDomain && post.domain != "i.imgur.com";
            var isImage =
                (post.isRedditMediaDomain || post.domain == "i.imgur.com") &&
                    !post.isVideo;
            var isVideo = post.isVideo;

            var widget;
            if (!isVideo) {
              widget = Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  if (post.preview.isNotEmpty)
                    Hero(
                      tag: post.preview.first.source.url.toString(),
                      child: AspectRatio(
                        aspectRatio: post.preview.first.source.width /
                            post.preview.first.source.height,
                        child: CachedNetworkImage(
                          imageUrl: post.preview.first.source.url.toString(),
                          progressIndicatorBuilder: (_, __, progress) {
                            if (progress.progress == null) {
                              return Container();
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: progress.progress,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  if (isLink)
                    Container(
                      width: double.infinity,
                      color: Colors.black54,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              post.domain,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.open_in_new, size: 20)
                          ],
                        ),
                      ),
                    )
                ],
              );
            } else {
              var url = post.data["secure_media"]["reddit_video"]
                      ["fallback_url"]
                  .toString();
              var width =
                  post.data["secure_media"]["reddit_video"]["width"] as int;
              var height =
                  post.data["secure_media"]["reddit_video"]["height"] as int;

              print("Video URL $url");
              widget =
                  RedditVideoPlayer(url: url, width: width, height: height);
              return widget;
            }

            return inkwellOverWidget(
              widget: widget,
              onTap: () {
                if (isImage) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ImageViewer(
                          post, post.preview.first.source.url.toString())));
                } else if (isLink) {
                  launch(post.url.toString());
                }
              },
            );
          },
        ),
        _buildActionButtons(context, post),
      ],
    );
  }

  Widget _buildSource(Submission post) {
    print("post.isSelf: ${post.isSelf}");
    print("post.isVideo: ${post.isVideo}");
    print("post.variants: ${post.variants}");
    print("post.url: ${post.url}");
    print("post.thumbnail: ${post.thumbnail.toString()}");
    for (int i = 0; i < post.preview.length; i++) {
      print(
          "preview[$i] = id: ${post.preview[i].id}, url: ${post.preview[i].source.url}");
    }
    print("post.variants: ${post.variants}");
    print("post.domain: ${post.domain}");
    print("post.isRedditMediaDomain: ${post.isRedditMediaDomain}");
    print("");

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
          ChangeNotifierProvider.value(
            value: context.read<PostsLocalState>().getOrCreate(post.id),
            builder: (_, __) => Score(post),
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
              Share.share(
                shortLink(context.read<AppModel>().reddit, post).toString(),
              );
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
}
