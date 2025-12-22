// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vent_reply.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VentReply _$VentReplyFromJson(Map<String, dynamic> json) => VentReply(
      id: json['id'] as String?,
      reply: json['reply'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String?,
      ventId: json['ventId'] as String?,
      parentId: json['parent_id'] as String?,
    );

Map<String, dynamic> _$VentReplyToJson(VentReply instance) => <String, dynamic>{
      'id': instance.id,
      'reply': instance.reply,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'userId': instance.userId,
      'ventId': instance.ventId,
      'parent_id': instance.parentId,
    };
