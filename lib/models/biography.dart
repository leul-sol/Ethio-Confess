import 'package:json_annotation/json_annotation.dart';

part 'biography.g.dart';

@JsonSerializable()
class Biography {
  final String id;
  final String category;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final int likesCount;

  Biography({
    required this.id,
    required this.category,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.likesCount = 0,
  });

  factory Biography.fromJson(Map<String, dynamic> json) =>
      _$BiographyFromJson(json);
  Map<String, dynamic> toJson() => _$BiographyToJson(this);
}
