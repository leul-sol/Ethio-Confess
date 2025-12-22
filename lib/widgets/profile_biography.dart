import 'package:flutter/material.dart';
import 'package:metsnagna/models/popular_entity.dart';
import 'package:metsnagna/utils/text_preview.dart';
import 'package:metsnagna/utils/time_duration.dart';
import 'package:metsnagna/utils/avatar_utils.dart';

class ProfileBiography extends StatelessWidget {
  final PopularEntity entity;

  ProfileBiography({
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.blue, // Blue border
          width: 37.8, // Approximate 1 cm in logical pixels
        ),
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Card(
        elevation: 4, // Moderate shadow
        shadowColor: Colors.grey.withOpacity(0.5), // Custom shadow color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
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
                  const SizedBox(width: 10),
                  Text(
                    entity.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                        style: TextStyle(fontSize: 12),
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
      ),
    );
  }
}
