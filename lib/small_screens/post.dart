import 'package:cached_network_image/cached_network_image.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:starboard/app_models/app_model.dart';
import 'package:starboard/app_models/posts.dart';
import 'package:starboard/small_screens/image_viewer.dart';
import 'package:starboard/small_screens/score.dart';
import 'package:starboard/util.dart';
import 'package:url_launcher/url_launcher.dart';

class LinearComment {
  int indentation;
  dynamic comment;

  LinearComment(this.indentation, this.comment);
}

class Post extends StatefulWidget {
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  Submission post;
  Future commentsRefreshed;

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
                  _buildTopSection(post),
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
                  _buildTopSection(post),
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
            _linearizeComments(post.comments, linearComments);

            return Scrollbar(
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: 1 + linearComments.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildTopSection(post);
                  }
                  var comment =
                      _buildComment(linearComments[index - 1].comment);
                  return _indentComment(
                      comment, linearComments[index - 1].indentation);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopSection(Submission post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(post),
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

            var widget = Stack(
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
                        placeholder: (_context, _) =>
                            Center(child: CircularProgressIndicator()),
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

  Widget _buildHeader(Submission post) {
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

  void _linearizeComments(CommentForest commentForest, List<LinearComment> dest,
      {level = 0}) {
    for (var c in commentForest.comments) {
      dest.add(LinearComment(level, c));
      if (c is Comment && c.replies != null) {
        _linearizeComments(c.replies, dest, level: level + 1);
      }
    }
  }

  Widget _buildComment(dynamic c) {
    if (c is MoreComments) {
      return Row(
        children: [
          Padding(padding: EdgeInsets.only(left: 5)),
          TextButton(child: Text("${c.count} more replies"), onPressed: () {}),
        ],
      );
    } else if (c is Comment) {
      // c.reddit.subreddit("u_${c.author}").populate().then((value) => print(value.iconImage));

      return Padding(
        padding: const EdgeInsets.only(left: 15, top: 15),
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: c.author == post.author ? Colors.blue : Colors.white,
                ),
              ),
              Text(
                " • ${formatDuration(DateTime.now().difference(c.createdUtc))}",
                style: TextStyle(color: Colors.grey),
              )
            ]),
            Padding(padding: EdgeInsets.only(top: 5)),
            Padding(
              // Avoid scrollbar covering the text
              padding: const EdgeInsets.only(right: 10),
              child: markdownRedditText(c.body),
            ),
            Padding(padding: EdgeInsets.only(top: 5)),
            _buildCommentActionButtons(c),
          ],
        ),
      );
    }
    assert(false, "Should never get here");
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
                  color:
                      c.vote == VoteState.downvoted ? Colors.blue : Colors.grey,
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

  Widget _indentComment(Widget comment, int indentation) {
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
