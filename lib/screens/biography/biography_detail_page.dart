// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:ethioconfess/models/popular_entity.dart';
// import 'package:ethioconfess/utils/time_duration.dart';
// import 'package:ethioconfess/providers/auth_provider.dart';

// import '../../providers/biography_providers.dart';
// import '../../utils/auth_utils.dart';

// class BiographyDetailPage extends ConsumerStatefulWidget {
//   final PopularEntity entity;
//   final PopularEntity? topentity;

//   const BiographyDetailPage({
//     Key? key,
//     required this.entity,
//     this.topentity,
//   }) : super(key: key);

//   @override
//   ConsumerState<BiographyDetailPage> createState() =>
//       _BiographyDetailPageState();
// }

// class _BiographyDetailPageState extends ConsumerState<BiographyDetailPage>
//     with SingleTickerProviderStateMixin {
//   late int likeCount;
//   bool? isLiked;
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   final TextEditingController _replyController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     likeCount = widget.entity.likeCount;

//     // Initialize animation controller
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );

//     // Create a scale animation
//     _scaleAnimation = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween<double>(begin: 1.0, end: 1.2),
//         weight: 50,
//       ),
//       TweenSequenceItem(
//         tween: Tween<double>(begin: 1.2, end: 1.0),
//         weight: 50,
//       ),
//     ]).animate(_controller);

//     // Check initial like status
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final userId = ref.read(userIdProvider);
//       if (userId != null) {
//         final result = await ref.read(hasUserLikedProvider({
//           'biography_id': widget.entity.id.toString(),
//           'user_id': userId,
//         }).future);

//         if (mounted) {
//           setState(() {
//             isLiked = result;
//           });
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _replyController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Profile Info
//                     Row(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               widget.entity.username,
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               timeAgo(
//                                   DateTime.tryParse(widget.entity.createdAt)),
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const Spacer(),
//                         // Like Button
//                         Row(
//                           children: [
//                             GestureDetector(
//                               //  onTap: userId == null
//                               // ? null
//                               // : () async {

//                               //     final params = {
//                               //       'biography_id': widget.entity.id.toString(),
//                               //       'user_id': userId,
//                               //     };
//                               //     _controller.forward(from: 0.0);
//                               //     if (isLiked ?? false) {
//                               //       setState(() {
//                               //         isLiked = false;
//                               //         likeCount--;
//                               //       });
//                               //       await ref.read(unlikeBiographyProvider(params).future);
//                               //     } else {
//                               //       setState(() {
//                               //         isLiked = true;
//                               //         likeCount++;
//                               //       });
//                               //       await ref.read(likeBiographyProvider(params).future);
//                               //     }
//                               //     ref.invalidate(hasUserLikedProvider(params));
//                               //   },
//                               onTap: () async {
//                                 // Check authentication before allowing like action
//                                 if (!await handleProtectedAction(
//                                   context,
//                                   action: ProtectedAction.like,
//                                   message: 'Please sign in to like biographies',
//                                 )) {
//                                   return;
//                                 }

//                                 final userId = ref.read(userIdProvider);
//                                 final params = {
//                                   'biography_id': widget.entity.id.toString(),
//                                   'user_id': userId!,
//                                 };
//                                 _controller.forward(from: 0.0);
//                                 if (isLiked ?? false) {
//                                   setState(() {
//                                     isLiked = false;
//                                     likeCount--;
//                                   });
//                                   await ref.read(
//                                       unlikeBiographyProvider(params).future);
//                                 } else {
//                                   setState(() {
//                                     isLiked = true;
//                                     likeCount++;
//                                   });
//                                   await ref.read(
//                                       likeBiographyProvider(params).future);
//                                 }
//                                 ref.invalidate(hasUserLikedProvider(params));
//                               },
//                               child: ScaleTransition(
//                                 scale: _scaleAnimation,
//                                 child: Icon(
//                                   isLiked ?? false
//                                       ? Icons.favorite
//                                       : Icons.favorite_border_sharp,
//                                   color: Colors.red,
//                                   size: 24,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               likeCount.toString(),
//                               style: const TextStyle(fontSize: 12),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
//                     // Content
//                     Text(
//                       widget.entity.content,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         height: 1.5,
//                       ),
//                       // textAlign: TextAlign.justify,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Add your reply input widget here if needed
//           // Similar to ReplyInput in vent_detail_screen.dart
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethioconfess/models/popular_entity.dart';
import 'package:ethioconfess/utils/time_duration.dart';
import 'package:ethioconfess/utils/avatar_utils.dart';

import '../../widgets/biography_widget/biography_like_button.dart';

class BiographyDetailPage extends ConsumerWidget {
  final PopularEntity entity;
  final PopularEntity? topentity;

  const BiographyDetailPage({
    Key? key,
    required this.entity,
    this.topentity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Info
                    Row(
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
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entity.username,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  timeAgo(parseApiDateTime(entity.createdAt)),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Like Button
                        BiographyLikeButton(
                          biographyId: entity.id.toString(),
                          initialLikeCount: entity.likeCount,
                          iconSize: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Content
                    Text(
                      entity.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
