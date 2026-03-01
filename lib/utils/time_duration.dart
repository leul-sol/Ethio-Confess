// import 'package:timeago/timeago.dart' as timeago;

// String timeAgo(DateTime? dateTime) {
//   print("Biography Created date $dateTime");
//   if (dateTime == null) return '';

//   // Use the original UTC time for comparison
//   final now = DateTime.now().toUtc();
//   final difference = now.difference(dateTime);

  // // Debugging prints
  // print("Now (UTC): $now");
  // print("DateTime (UTC): $dateTime");
  // print("Difference: $difference");

//   if (difference.inDays > 0) {
//     return timeago.format(dateTime);
//   } else if (difference.inHours > 0) {
//     return '${difference.inHours}h ago';
//   } else if (difference.inMinutes > 0) {
//     return '${difference.inMinutes}m ago';
//   } else if (difference.inSeconds > 0) {
//     return '${difference.inSeconds}s ago'; // Handle seconds explicitly
//   } else {
//     return 'just now';
//   }
// }
import 'package:timeago/timeago.dart' as timeago;

/// Parses an API timestamp string (often UTC without "Z") to local DateTime.
DateTime? parseApiDateTime(String? dateTimeStr) {
  if (dateTimeStr == null) return null;
  final parsed = DateTime.tryParse(dateTimeStr);
  if (parsed == null) return null;
  final hasTimezone = dateTimeStr.endsWith('Z') ||
      dateTimeStr.contains('+') ||
      RegExp(r'-\d{2}:?\d{2}$').hasMatch(dateTimeStr);
  if (!hasTimezone) {
    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
    ).toLocal();
  }
  return parsed.toLocal();
}

String timeAgo(DateTime? dateTime) {
  // print("Biography Created date $dateTime");
  if (dateTime == null) return '';

  // Convert to local time if it's in UTC
  final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
  // print("Biography Created date Local $localDateTime");

// Biography Created date 2025-03-30 19:26:39.452685Z
// I/flutter ( 5435): Biography Created date Local 2025-03-30 22:26:39.452685
  // Get current local time for comparison
  final now = DateTime.now();
  final difference = now.difference(localDateTime);

  // Debugging prints
  // print("Now (Local): $now");
  // print("DateTime (Local): $localDateTime");
  // print("Difference: $difference");

  if (difference.inDays > 0) {
    return timeago.format(localDateTime);
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inSeconds > 0) {
    return '${difference.inSeconds}s ago'; // Handle seconds explicitly
  } else {
    return 'just now';
  }
}
