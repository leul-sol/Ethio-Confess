class BiographyEntity {
  final String id;
  final String category;
  final String createdAt;
  final String updatedAt;
  final String content;
  final String userId;
  final int totalLikeCount;

  BiographyEntity({
    required this.id,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.content,
    required this.userId,
    required this.totalLikeCount,
  });

  factory BiographyEntity.fromJson(Map<String, dynamic> json) {
    return BiographyEntity(
      id: json['id'] as String,
      category: json['category'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      content: json['content'] as String,
      userId: json['user_id'] as String,
      totalLikeCount: json['total_like_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'content': content,
      'user_id': userId,
      'total_like_count': totalLikeCount,
    };
  }
} 