import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'vent_reply.dart';

part 'vent.g.dart';

@JsonSerializable()
class Vent {
  final String? id;
  final String? content;
  @JsonKey(
    name: 'created_at',
    fromJson: _dateFromJson,
    toJson: _dateToJson,
  )
  final DateTime? createdAt;
  @JsonKey(
    name: 'updated_at',
    fromJson: _dateFromJson,
    toJson: _dateToJson,
  )
  final DateTime? updatedAt;
  final String? userId;
  final User? user;
  final List<VentReply>? ventReplies;
  @JsonKey(name: 'ventreplies_aggregate')
  final Map<String, dynamic>? ventRepliesAggregate;
  @JsonKey(name: 'vent_category')
  final Map<String, dynamic>? ventCategory;

  Vent({
    this.id,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.user,
    this.ventReplies,
    this.ventRepliesAggregate,
    this.ventCategory,
  });

  int get replyCount {
    return ventRepliesAggregate?['aggregate']?['count'] ?? 0;
  }

  // Custom date parser
  static DateTime? _dateFromJson(String? date) {
    if (date == null) return null;
    try {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) {
        return parsed.toLocal();
      }
      // Attempt to sanitize minimal timestamps like 'YYYY-MM-DDTH' or 'YYYY-MM-DDTHH'
      final regex = RegExp(r"^\d{4}-\d{2}-\d{2}T\d{1,2}$");
      if (regex.hasMatch(date)) {
        final parts = date.split('T');
        final day = parts[0];
        final hourStr = parts[1];
        final hour = hourStr.padLeft(2, '0');
        final sanitized = '${day}T${hour}:00:00Z';
        final fallback = DateTime.tryParse(sanitized);
        if (fallback != null) {
          return fallback.toLocal();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? _dateToJson(DateTime? date) {
    if (date == null) return null;
    return date.toUtc().toIso8601String();
  }

  factory Vent.fromJson(Map<String, dynamic> json) {
    print('Raw created_at: ${json['created_at']}'); // Debug print
    final vent = _$VentFromJson(json);
    print('Parsed createdAt: ${vent.createdAt}'); // Debug print
    return vent;
  }
  Map<String, dynamic> toJson() => _$VentToJson(this);
}
