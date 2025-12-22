// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vent _$VentFromJson(Map<String, dynamic> json) => Vent(
      id: json['id'] as String?,
      content: json['content'] as String?,
      createdAt: Vent._dateFromJson(json['created_at'] as String?),
      updatedAt: Vent._dateFromJson(json['updated_at'] as String?),
      userId: json['userId'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      ventReplies: (json['ventReplies'] as List<dynamic>?)
          ?.map((e) => VentReply.fromJson(e as Map<String, dynamic>))
          .toList(),
      ventRepliesAggregate:
          json['ventreplies_aggregate'] as Map<String, dynamic>?,
      ventCategory: json['vent_category'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$VentToJson(Vent instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'created_at': Vent._dateToJson(instance.createdAt),
      'updated_at': Vent._dateToJson(instance.updatedAt),
      'userId': instance.userId,
      'user': instance.user?.toJson(),
      'ventReplies': instance.ventReplies,
      'ventreplies_aggregate': instance.ventRepliesAggregate,
      'vent_category': instance.ventCategory,
    };
