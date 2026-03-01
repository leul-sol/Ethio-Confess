import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethioconfess/models/popular_entity.dart';
import 'package:ethioconfess/screens/biography/biography_detail_page.dart';
import 'package:ethioconfess/utils/time_duration.dart';
import 'package:ethioconfess/utils/avatar_utils.dart';
import 'package:ethioconfess/widgets/biography_widget/biography_like_button.dart';

class TopBiographyCard extends ConsumerWidget {
  final PopularEntity bio;

  const TopBiographyCard({
    Key? key,
    required this.bio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🚨🚨🚨 [TopBiographyCard] BUILD METHOD CALLED! 🚨🚨🚨');
    print('🎨 [TopBiographyCard] Building card for bio: ${bio.username}');
    print('🎨 [TopBiographyCard] Profile image: ${bio.profileImage}');
    print('🎨 [TopBiographyCard] Full bio object: $bio');
    
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
        height: 150,
        width: 300,
        decoration: const BoxDecoration(
          color: Color(0xFFE8F1FF),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          border: Border(
            left: BorderSide(
              color: Color(0xFF2D6BEF),
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: bio.profileImage != null && bio.profileImage!.isNotEmpty
                        ? AvatarUtils.getProfileImage(bio.profileImage)
                        : null,
                    backgroundColor: Colors.grey.shade200,
                    child: bio.profileImage == null || bio.profileImage!.isEmpty
                        ? Icon(
                            Icons.person,
                            color: Colors.grey.shade600,
                            size: 24,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                bio.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeAgo(parseApiDateTime(bio.createdAt)),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  BiographyLikeButton(
                    biographyId: bio.id.toString(),
                    initialLikeCount: bio.likeCount,
                    iconSize: 16,
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