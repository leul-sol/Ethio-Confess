import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethioconfess/models/popular_entity.dart';
import 'package:ethioconfess/screens/biography/biography_detail_page.dart';
import 'package:ethioconfess/utils/avatar_utils.dart';
import 'package:ethioconfess/utils/time_duration.dart';
import 'package:ethioconfess/widgets/biography_widget/biography_like_button.dart';

class BiographyListItem extends ConsumerWidget {
  final PopularEntity bio;

  const BiographyListItem({
    Key? key,
    required this.bio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String timeAgoStr = timeAgo(parseApiDateTime(bio.createdAt));
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
                  timeAgoStr,
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