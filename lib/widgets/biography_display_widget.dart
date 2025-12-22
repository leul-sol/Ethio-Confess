import 'package:flutter/material.dart';
import 'package:ethioconfess/models/popular_entity.dart';
import 'package:ethioconfess/utils/text_preview.dart';
import 'package:ethioconfess/utils/time_duration.dart';
import 'package:ethioconfess/utils/avatar_utils.dart';

class CustomCard extends StatelessWidget {
  final PopularEntity entity;

  const CustomCard({
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    print('🎨 [CustomCard] Building card for entity: ${entity.username}');
    print('🎨 [CustomCard] Profile image: ${entity.profileImage}');
    print('🎨 [CustomCard] Full entity object: $entity');
    
    return Column(
      children: [
        SizedBox(height: 45),
        Card(
          elevation: 6,
          shadowColor: Colors.grey.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Container(
            width: 286,
            height: 156,
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              border: Border(
                left: BorderSide(
                  color: const Color(0xFF4169E1),
                  width: 7,
                ),
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.all(2)),
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
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      textPreview(entity.content, 70),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Icon(
                            Icons.favorite_border_rounded,
                            color: Colors.red[900],
                            size: 20,
                          ),
                          Text(
                            '${entity.likeCount}',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '${timeAgo(DateTime.parse(entity.createdAt))}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
