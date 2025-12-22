import 'package:flutter/material.dart';
import 'package:ethioconfess/models/popular_entity.dart';
import 'package:ethioconfess/utils/text_preview.dart';
import 'package:ethioconfess/utils/time_duration.dart';
import 'package:ethioconfess/utils/avatar_utils.dart';

class NonPopularBiographyWidget extends StatelessWidget {
  final PopularEntity entity;

  NonPopularBiographyWidget({
    super.key,
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    print('🎨 [NonPopularBiographyWidget] Building widget for entity: ${entity.username}');
    print('🎨 [NonPopularBiographyWidget] Profile image: ${entity.profileImage}');
    print('🎨 [NonPopularBiographyWidget] Full entity object: $entity');
    
    return Container(
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
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: entity.profileImage != null && entity.profileImage!.isNotEmpty
                      ? AvatarUtils.getProfileImage(entity.profileImage)
                      : null,
                  backgroundColor: Colors.grey.shade200,
                  child: entity.profileImage == null || entity.profileImage!.isEmpty
                      ? Icon(
                          Icons.person,
                          color: Colors.grey.shade600,
                          size: 24,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              textPreview(entity.content, 100),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.red[900],
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      entity.likeCount.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  timeAgo(DateTime.parse(entity.createdAt)),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
