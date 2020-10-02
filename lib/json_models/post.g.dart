// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentsJsonModel _$CommentsJsonModelFromJson(Map<String, dynamic> json) {
  return CommentsJsonModel(
    json['data'] == null
        ? null
        : CommentsJsonModelData.fromJson(json['data'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CommentsJsonModelToJson(CommentsJsonModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

CommentsJsonModelData _$CommentsJsonModelDataFromJson(
    Map<String, dynamic> json) {
  return CommentsJsonModelData(
    (json['children'] as List)
        ?.map((e) => e == null
            ? null
            : CommentJsonModel.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CommentsJsonModelDataToJson(
        CommentsJsonModelData instance) =>
    <String, dynamic>{
      'children': instance.children,
    };

CommentJsonModel _$CommentJsonModelFromJson(Map<String, dynamic> json) {
  return CommentJsonModel(
    json['data'] == null
        ? null
        : CommentJsonModelData.fromJson(json['data'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CommentJsonModelToJson(CommentJsonModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

CommentJsonModelData _$CommentJsonModelDataFromJson(Map<String, dynamic> json) {
  return CommentJsonModelData(
    json['replies'],
  )
    ..author = json['author'] as String
    ..body = json['body'] as String
    ..score = json['score'] as int;
}

Map<String, dynamic> _$CommentJsonModelDataToJson(
        CommentJsonModelData instance) =>
    <String, dynamic>{
      'author': instance.author,
      'body': instance.body,
      'score': instance.score,
      'replies': instance.replies,
    };
