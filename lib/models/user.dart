import 'package:json_annotation/json_annotation.dart';
import 'biography.dart';
import 'vent.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String? id;
  final String? email;
  final String? username;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  final String? phone_no;
  final String? profile_image;
  final List<Biography>? biographies;
  final List<Vent>? vents;

  User({
    this.id,
    this.email,
    this.username,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
    this.phone_no,
    this.profile_image,
    this.biographies,
    this.vents,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
