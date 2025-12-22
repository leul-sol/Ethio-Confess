import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:metsnagna/models/biography_entity.dart';
import 'package:metsnagna/models/popular_entity.dart';
// import 'package:metsnagna/providers/biography_providers.dart';
import 'package:metsnagna/screens/biography/biography_detail_page.dart';
import 'package:metsnagna/widgets/biography_widget/biography_like_button.dart';
import 'package:metsnagna/utils/avatar_utils.dart';
// import 'package:shimmer/shimmer.dart';

class BiographyListItem extends ConsumerWidget {
  final PopularEntity bio;

  const BiographyListItem({
    Key? key,
    required this.bio,
  }) : super(key: key);

  String _getTimeAgo(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      // Parse the UTC timestamp with timezone offset
      final dateTime = DateTime.parse(dateTimeStr).toUtc();
      final now = DateTime.now().toUtc();
      
      final difference = now.difference(dateTime);

      // Convert duration to appropriate format
      if (difference.inDays >= 28) {
        final months = (difference.inDays / 30).floor();
        return months == 1 ? '1 month ago' : '$months months ago';
      } else if (difference.inDays >= 7) {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      } else if (difference.inDays > 0) {
        return difference.inDays == 1 ? 'yesterday' : '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'just now';
      }
    } catch (e) {
      print('Error parsing date: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🚨🚨🚨 [BiographyListItem] BUILD METHOD CALLED! 🚨🚨🚨');
    String timeAgo = _getTimeAgo(bio.createdAt);
    print("🎨 [BiographyListItem] Building list item for bio: ${bio.username}");
    print("🎨 [BiographyListItem] Profile image: ${bio.profileImage}");
    print("🎨 [BiographyListItem] Full bio object: $bio");

    // final userProfileAsync = ref.watch(userProfileProvider(bio.userId));

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BiographyDetailPage(entity: bio),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24.0),
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: bio.profileImage != null && bio.profileImage!.isNotEmpty
                      ? AvatarUtils.getProfileImage(bio.profileImage)
                      : null,
                  backgroundColor: Colors.grey.shade200,
                  child: bio.profileImage == null || bio.profileImage!.isEmpty
                      ? Icon(
                          Icons.person,
                          color: Colors.grey.shade600,
                          size: 20,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 100,
              ),
              child: Text(
                bio.content,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.justify,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                BiographyLikeButton(
                  biographyId: bio.id.toString(),
                  initialLikeCount: bio.likeCount,
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 