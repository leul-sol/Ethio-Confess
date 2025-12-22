import 'package:flutter/material.dart';

void main() {
  print('🚨🚨🚨 [popular_entity.dart] FILE LOADED! 🚨🚨🚨');
}

class PopularEntity {
  final String? id;
  final String? category;
  final String createdAt;
  final String content;
  final String username;
  final int likeCount;
  final String? profileImage;

  PopularEntity({
    this.id,
    this.category,
    required this.createdAt,
    required this.content,
    required this.username,
    required this.likeCount,
    this.profileImage,
  });

  // Factory constructor to create an instance from JSON
  factory PopularEntity.fromJson(Map<String, dynamic> json) {
    print('🚨🚨🚨 [PopularEntity.fromJson] METHOD CALLED! 🚨🚨🚨');
    print('PopularEntity.fromJson - Raw JSON: $json');
    print('PopularEntity.fromJson - User data: ${json['user']}');
    print('PopularEntity.fromJson - Profile image: ${json['user']?['profile_image']}');
    
    return PopularEntity(
      id: json['id'],
      category: json['category'],

      // createdAt: DateTime.parse(json['created_at']),
      createdAt: json['created_at'],
      content: json['content'],
      username: json['user']['username'],
      likeCount: json['biographylikes_aggregate']['aggregate']['count'] as int,
      profileImage: json['user']?['profile_image'],
    );
  }

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'created_at': createdAt,
      'content': content,
      'user': {
        'username': username,
      },
      'biographylikes_aggregate': {
        'aggregate': {
          'count': likeCount,
        },
      },
    };
  }
}

class LikecountEntity {
  int count;
  LikecountEntity({required this.count});
  factory LikecountEntity.fromJson(Map<String, dynamic> json) {
    return LikecountEntity(
      count: json['aggregate']['count'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'aggregate': {
        'count': count,
      }
    };
  }
}

class VentEntity {
  final String id;
  final DateTime createdAt;
  final String content;

  VentEntity({
    required this.id,
    required this.createdAt,
    required this.content,
  });

  factory VentEntity.fromJson(Map<String, dynamic> json) {
    return VentEntity(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      content: json['content'] as String,
    );
  }
}

class UserEntity {
  final DateTime created_at;
  final String username;

  UserEntity({
    required this.created_at,
    required this.username,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      created_at: DateTime.parse(json['created_at'] as String),
      username: json['username'] as String,
    );
  }
}
