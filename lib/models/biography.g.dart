// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biography.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Biography _$BiographyFromJson(Map<String, dynamic> json) => Biography(
      id: json['id'] as String,
      category: json['category'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BiographyToJson(Biography instance) => <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'userId': instance.userId,
      'likesCount': instance.likesCount,
    };
