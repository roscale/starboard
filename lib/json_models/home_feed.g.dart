// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeFeedJsonModel _$HomeFeedJsonModelFromJson(Map<String, dynamic> json) {
  return HomeFeedJsonModel(
    json['data'] == null
        ? null
        : HomeFeedJsonModelData.fromJson(json['data'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$HomeFeedJsonModelToJson(HomeFeedJsonModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

HomeFeedJsonModelData _$HomeFeedJsonModelDataFromJson(
    Map<String, dynamic> json) {
  return HomeFeedJsonModelData()
    ..children = (json['children'] as List)
        ?.map((e) => e == null
            ? null
            : HomeFeedPostJsonModel.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..after = json['after'] as String;
}

Map<String, dynamic> _$HomeFeedJsonModelDataToJson(
        HomeFeedJsonModelData instance) =>
    <String, dynamic>{
      'children': instance.children,
      'after': instance.after,
    };

HomeFeedPostJsonModel _$HomeFeedPostJsonModelFromJson(
    Map<String, dynamic> json) {
  return HomeFeedPostJsonModel(
    json['data'] == null
        ? null
        : HomeFeedPostJsonModelData.fromJson(
            json['data'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$HomeFeedPostJsonModelToJson(
        HomeFeedPostJsonModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

HomeFeedPostJsonModelData _$HomeFeedPostJsonModelDataFromJson(
    Map<String, dynamic> json) {
  return HomeFeedPostJsonModelData()
    ..title = json['title'] as String
    ..author = json['author'] as String
    ..subreddit = json['subreddit'] as String
    ..ups = json['ups'] as int
    ..post_hint = json['post_hint'] as String
    ..url = json['url'] as String
    ..num_comments = json['num_comments'] as int
    ..permalink = json['permalink'] as String
    ..thumbnail = json['thumbnail'] as String;
}

Map<String, dynamic> _$HomeFeedPostJsonModelDataToJson(
        HomeFeedPostJsonModelData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'author': instance.author,
      'subreddit': instance.subreddit,
      'ups': instance.ups,
      'post_hint': instance.post_hint,
      'url': instance.url,
      'num_comments': instance.num_comments,
      'permalink': instance.permalink,
      'thumbnail': instance.thumbnail,
    };
