import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class CommentsJsonModel {
  CommentsJsonModel(this.data);

  CommentsJsonModelData data;

  factory CommentsJsonModel.fromJson(Map<String, dynamic> json) =>
      _$CommentsJsonModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentsJsonModelToJson(this);
}

@JsonSerializable()
class CommentsJsonModelData {
  CommentsJsonModelData(this.children);

  List<CommentJsonModel> children;

  factory CommentsJsonModelData.fromJson(Map<String, dynamic> json) =>
      _$CommentsJsonModelDataFromJson(json);

  Map<String, dynamic> toJson() => _$CommentsJsonModelDataToJson(this);
}

@JsonSerializable()
class CommentJsonModel {
  CommentJsonModel(this.data);

  CommentJsonModelData data;

  factory CommentJsonModel.fromJson(Map<String, dynamic> json) =>
      _$CommentJsonModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentJsonModelToJson(this);
}

@JsonSerializable()
class CommentJsonModelData {
  CommentJsonModelData(replies) {
    if (!(replies is List)) {
      this.replies = [];
    } else {
      this.replies = replies;
    }
  }

  String author;
  String body;
  int score;
  List<CommentJsonModel> replies;

  factory CommentJsonModelData.fromJson(Map<String, dynamic> json) =>
      _$CommentJsonModelDataFromJson(json);

  Map<String, dynamic> toJson() => _$CommentJsonModelDataToJson(this);
}
