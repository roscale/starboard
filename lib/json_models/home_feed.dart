import 'package:json_annotation/json_annotation.dart';

part 'home_feed.g.dart';

@JsonSerializable()
class HomeFeedJsonModel {
  HomeFeedJsonModel(this.data);

  HomeFeedJsonModelData data;

  factory HomeFeedJsonModel.fromJson(Map<String, dynamic> json) =>
      _$HomeFeedJsonModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeFeedJsonModelToJson(this);
}

@JsonSerializable()
class HomeFeedJsonModelData {
  HomeFeedJsonModelData();

  List<HomeFeedPostJsonModel> children;
  String after;

  factory HomeFeedJsonModelData.fromJson(Map<String, dynamic> json) =>
      _$HomeFeedJsonModelDataFromJson(json);

  Map<String, dynamic> toJson() => _$HomeFeedJsonModelDataToJson(this);
}

@JsonSerializable()
class HomeFeedPostJsonModel {
  HomeFeedPostJsonModel(this.data);

  HomeFeedPostJsonModelData data;

  factory HomeFeedPostJsonModel.fromJson(Map<String, dynamic> json) =>
      _$HomeFeedPostJsonModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeFeedPostJsonModelToJson(this);
}

@JsonSerializable()
class HomeFeedPostJsonModelData {
  HomeFeedPostJsonModelData();

  String title;
  String author;
  String subreddit;
  int ups;
  String post_hint;
  String url;
  int num_comments;
  String permalink;
  String thumbnail;

  factory HomeFeedPostJsonModelData.fromJson(Map<String, dynamic> json) =>
      _$HomeFeedPostJsonModelDataFromJson(json);

  Map<String, dynamic> toJson() => _$HomeFeedPostJsonModelDataToJson(this);
}
