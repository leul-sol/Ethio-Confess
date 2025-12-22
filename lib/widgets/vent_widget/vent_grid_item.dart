import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/vent.dart';
import '../../screens/vent/vent_detail_screen.dart';
import '../../utils/avatar_utils.dart';

class VentGridItem extends StatelessWidget {
  final Vent vent;

  const VentGridItem({
    Key? key,
    required this.vent,
  }) : super(key: key);

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return timeago.format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    String timeAgo = '';
    if (vent.createdAt != null) {
      try {
        print("Vent ${vent.createdAt}");
        timeAgo = _getTimeAgo(vent.createdAt);
      } catch (e) {
        print('Error formatting time: $e');
        timeAgo = '';
      }
    }

    final cardWidth = MediaQuery.of(context).size.width * 0.4;
    final cardHeight = cardWidth * 1.5;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VentDetailScreen(
              ventId: vent.id ?? '',
            ),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) {
                  // print("vent.user ${vent.user?.profile_image}");
                  final profileImage = vent.user?.profile_image;
                  print("profileImage: $profileImage");
                  final ImageProvider? avatarImage = AvatarUtils.getProfileImage(profileImage);
                  print("avatarImage: $avatarImage");
                  print("Will show person icon: ${avatarImage == null}");
                  return CircleAvatar(
                    radius: 14,
                    backgroundImage: avatarImage,
                    backgroundColor: Colors.grey.shade200,
                    child: avatarImage == null
                        ? const Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.grey,
                          )
                        : null,
                  );
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  vent.content ?? '',
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const Divider(color: Color(0xFF4169E1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeAgo, // Show timeago on the left
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.repeat, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        vent.replyCount.toString(),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
