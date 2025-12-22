// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      lastLogin: json['lastLogin'] == null
          ? null
          : DateTime.parse(json['lastLogin'] as String),
      phone_no: json['phone_no'] as String?,
      profile_image: json['profile_image'] as String?,
      biographies: (json['biographies'] as List<dynamic>?)
          ?.map((e) => Biography.fromJson(e as Map<String, dynamic>))
          .toList(),
      vents: (json['vents'] as List<dynamic>?)
          ?.map((e) => Vent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'lastLogin': instance.lastLogin?.toIso8601String(),
      'phone_no': instance.phone_no,
      'profile_image': instance.profile_image,
      'biographies': instance.biographies?.map((b) => b.toJson()).toList(),
      'vents': instance.vents?.map((v) => v.toJson()).toList(),
    };
