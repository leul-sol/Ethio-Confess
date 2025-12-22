import 'package:json_annotation/json_annotation.dart';

part 'vent_reply.g.dart';

@JsonSerializable()
class VentReply {
  final String? id;
  final String? reply;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final String? ventId;
  final String? parentId;

  VentReply({
    this.id,
    this.reply,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.ventId,
    this.parentId,
  });

  factory VentReply.fromJson(Map<String, dynamic> json) =>
      _$VentReplyFromJson(json);
  Map<String, dynamic> toJson() => _$VentReplyToJson(this);
}
