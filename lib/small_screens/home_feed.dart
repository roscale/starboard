import 'package:cached_network_image/cached_network_image.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:starboard/app_models/app_model.dart';
import 'package:starboard/app_models/home_feed.dart';
import 'package:starboard/app_models/posts.dart';
import 'package:starboard/small_screens/reddit_video_player.dart';
import 'package:starboard/small_screens/image_viewer.dart';
import 'package:starboard/small_screens/score.dart';
import 'package:starboard/small_screens/subreddit_search_bar.dart';
import 'package:starboard/util.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeFeed extends StatefulWidget {
  @override
  _HomeFeedState createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  var _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Download more posts when approaching the end of the list.
    _scrollController.addListener(() {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent - 1000) {
        var appModel = context.read<AppModel>();
        context.read<HomeFeedModel>().fetchMorePosts(appModel.reddit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {},
        ),
        title: SubredditSearchBar(),
        centerTitle: true,
        actions: [
          // Logout button.
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await context.read<AppModel>().deleteSavedCredentials();
              Navigator.of(context).pushReplacementNamed("/");
            },
            tooltip: "Logout",
          )
        ],
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

  Widget _buildListView(List<Submission> posts) {
    return ListView.separated(
      separatorBuilder: (context, i) => Divider(height: 0),
      controller: _scrollController,
      itemCount: posts.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index < posts.length) {
          return _buildPost(posts[index]);
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildPost(Submission post) {
    return InkWell(
      splashColor: Color(0x552196F3),
      onTap: () {
        context.read<PostsLocalState>().getOrCreate(post.id).visit();
        // TODO: how to mark as visited?
        // post.markRead();
        return Navigator.of(context).pushNamed('/comments', arguments: post);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildTitleAndThumbnail(Submission post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "r/${post.subreddit.displayName} • ${formatDuration(DateTime.now().difference(post.createdUtc))}",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 5),
            Container(
              // Leave some space for the thumbnail
              width: !post.isSelf
                  ? MediaQuery.of(context).size.width - 120
                  : MediaQuery.of(context).size.width - 30,
              child: ChangeNotifierProvider.value(
                value: context.read<PostsLocalState>().getOrCreate(post.id),
                builder: (context, __) {
                  var localState = context.watch<PostLocalState>();
                  var visited;
                  if (localState.visited != null) {
                    visited = localState.visited;
                  } else {
                    visited = post.visited;
                  }

                  return Text(
                    HtmlUnescape().convert(post.title),
                    style: TextStyle(
                        fontSize: 14,
                        color: visited ? Colors.grey : Colors.white),
                  );
                },
              ),
            ),
          ],
        ),
        Builder(
          builder: (_) {
            if (post.isSelf) {
              return Container();
            }

            var isLink = !post.isRedditMediaDomain;
            var isImage =
                (post.isRedditMediaDomain || post.domain == "i.imgur.com") &&
                    !post.isVideo;
            var isVideo = post.isVideo;

            String thumbnail;
            // Some thumbnails don't contain urls for some reason
            // ex: default, image, nsfw
            if (post.thumbnail.scheme.isNotEmpty) {
              thumbnail = post.thumbnail.toString();
            } else if (post.preview.isNotEmpty) {
              thumbnail = post.preview.first.source.url.toString();
            }

            return ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: Builder(builder: (_) {
                var thumbnailWidget;
                if (thumbnail == null) {
                  thumbnailWidget = Container(
                    width: 85,
                    height: 60,
                    color: Colors.grey.shade800,
                    child: Icon(Icons.link),
                  );
                } else {
                  thumbnailWidget = CachedNetworkImage(
                    fadeInDuration: Duration(milliseconds: 200),
                    imageUrl: thumbnail,
                    width: 85,
                    height: 60,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  );
                }

                if (isImage) {
                  return inkwellOverWidget(
                      widget: thumbnailWidget,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ImageViewer(
                              post,
                              post.preview.first.source.url.toString(),
                            ),
                          ),
                        );
                      });
                } else if (isLink) {
                  thumbnailWidget = Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      thumbnailWidget,
                      Container(
                        width: 85,
                        color: Colors.black54,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            post.domain,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  );

                  return inkwellOverWidget(
                    widget: thumbnailWidget,
                    onTap: () {
                      launch(post.url.toString());
                    },
                  );
                } else if (isVideo) {
                  thumbnailWidget = Stack(
                    alignment: AlignmentDirectional.bottomStart,
                    children: [
                      thumbnailWidget,
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Icon(Icons.play_arrow, size: 20),
                        ),
                      ),
                    ],
                  );

                  return inkwellOverWidget(
                    widget: thumbnailWidget,
                    onTap: () {
                      var url = post.data["secure_media"]["reddit_video"]
                              ["fallback_url"]
                          .toString();
                      var width = post.data["secure_media"]["reddit_video"]
                          ["width"] as int;
                      var height = post.data["secure_media"]["reddit_video"]
                          ["height"] as int;

                      print("Video URL $url");

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RedditVideoPlayer(
                            fullscreen: true,
                            url: url,
                            width: width,
                            height: height,
                            post: post,
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  assert(false);
                  return Container();
                }
              }),
            );
          },
        )
      ],
    );
  }

  Widget _buildActionButtons(Submission post) {
    return SizedBox(
      width: 290,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ChangeNotifierProvider.value(
            value: context.read<PostsLocalState>().getOrCreate(post.id),
            builder: (_, __) => Score(post),
          ),
          InkWell(
            onTap: () {
              context.read<PostsLocalState>().getOrCreate(post.id).visit();
              // TODO: how to mark as visited?
              // post.markRead();
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
