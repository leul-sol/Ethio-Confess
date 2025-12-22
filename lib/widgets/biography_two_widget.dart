// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:ethioconfess/models/popular_entity.dart';
// import 'package:ethioconfess/providers/biography_providers.dart';
// import 'package:ethioconfess/screens/detail_questions.dart';
// import 'package:ethioconfess/services/biography_page_services.dart';
// import 'package:ethioconfess/services/storage_service.dart';
// import 'package:ethioconfess/utils/text_preview.dart';
// import 'package:ethioconfess/utils/time_duration.dart';

// class BiographyTwoWidget extends ConsumerStatefulWidget {
//   final PopularEntity entity;

//   BiographyTwoWidget({required this.entity});

//   @override
//   ConsumerState<BiographyTwoWidget> createState() =>
//       _CustomColoredWidgetState();
// }

// class _CustomColoredWidgetState extends ConsumerState<BiographyTwoWidget> {
//   String? userId;
//   final StorageService _storageService = StorageService();
//   bool isLiked = false;
//   int likeCount = 0;

//   Color _getRandomColorWithHighOpacity() {
//     final Random random = Random();
//     return Color.fromARGB(
//       255,
//       200 + random.nextInt(56),
//       200 + random.nextInt(56),
//       200 + random.nextInt(56),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadUserId();
//     if (widget.entity.id != null) {
//       final currentCount =
//           ref.read(biographyLikeCountProvider(widget.entity.id!));
//       likeCount = currentCount ?? widget.entity.likeCount;
//     }
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (widget.entity.id != null) {
//       final currentCount =
//           ref.read(biographyLikeCountProvider(widget.entity.id!));
//       likeCount = currentCount ?? 0;
//     }
//   }

//   Future<void> _loadUserId() async {
//     final token = await _storageService.getToken();
//     if (token != null) {
//       final decodedToken = JwtDecoder.decode(token);
//       final hasuraClaims = decodedToken['https://hasura.io/jwt/claims'];
//       if (hasuraClaims != null) {
//         setState(() {
//           userId = hasuraClaims['x-hasura-user-id'];
//           _checkIfLiked();
//         });
//       }
//     }
//   }

//   Future<void> _checkIfLiked() async {
//     if (userId != null && widget.entity.id != null) {
//       final params = {
//         'biography_id': widget.entity.id!,
//         'user_id': userId!,
//       };

//       try {
//         // First check the global state
//         final globalLikeState = ref.read(biographyLikesStateProvider(params));
//         if (globalLikeState != null) {
//           setState(() {
//             isLiked = globalLikeState;
//             likeCount =
//                 ref.read(biographyLikeCountProvider(widget.entity.id!)) ??
//                     widget.entity.likeCount;
//           });
//           return;
//         }

//         // If not in global state, check from API
//         final hasLiked = await ref.read(hasUserLikedProvider(params).future);

//         setState(() {
//           isLiked = hasLiked;
//           likeCount = widget.entity.likeCount;
//         });

//         // Update global state
//         ref.read(biographyLikesStateProvider(params).notifier).state = hasLiked;
//         ref.read(biographyLikeCountProvider(widget.entity.id!).notifier).state =
//             likeCount;
//       } catch (e) {
//         print('Error checking like status: $e');
//       }
//     }
//   }

//   Future<void> _toggleLike() async {
//     if (userId == null || widget.entity.id == null) return;

//     try {
//       final params = {
//         'biography_id': widget.entity.id!,
//         'user_id': userId!,
//       };

//       // Store previous state in case of error
//       final previousIsLiked = isLiked;
//       final previousLikeCount = likeCount;

//       // Optimistically update UI
//       setState(() {
//         isLiked = !isLiked;
//         likeCount = isLiked ? likeCount + 1 : likeCount - 1;
//       });

//       // Update global state immediately
//       ref.read(biographyLikesStateProvider(params).notifier).state = isLiked;
//       ref.read(biographyLikeCountProvider(widget.entity.id!).notifier).state =
//           likeCount;

//       // Make API call
//       if (isLiked) {
//         await ref.read(likeBiographyProvider(params).future);
//       } else {
//         await ref.read(unlikeBiographyProvider(params).future);
//       }

//       // Refresh the data
//       ref.invalidate(biographyProvider(Category.Family));
//       ref.invalidate(biographyProvider(Category.Relationship));
//       ref.invalidate(biographyProvider(Category.Health));
//       ref.invalidate(hasUserLikedProvider(params));
//     } catch (e) {
//       // Revert to previous state on error
//       setState(() {
//         isLiked = !isLiked; // Toggle back to previous state
//         likeCount =
//             isLiked ? likeCount + 1 : likeCount - 1; // Recalculate count
//       });

//       final params = {
//         'biography_id': widget.entity.id!,
//         'user_id': userId!,
//       };

//       // Revert global state

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.entity.id != null) {
//       // Watch like count changes
//       final currentLikeCount =
//           ref.watch(biographyLikeCountProvider(widget.entity.id!));
//       if (currentLikeCount != likeCount) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           setState(() {
//             likeCount = currentLikeCount ?? 0;
//           });
//         });
//       }

//       // Watch like state changes
//       if (userId != null) {
//         final params = {
//           'biography_id': widget.entity.id!,
//           'user_id': userId!,
//         };
//         final currentLikeState = ref.watch(biographyLikesStateProvider(params));
//         if (currentLikeState != isLiked) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             setState(() {
//               isLiked = currentLikeState ?? false;
//             });
//           });
//         }
//       }
//     }

//     Color randomColor = _getRandomColorWithHighOpacity();

//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Padding(
//                 padding: EdgeInsets.only(left: 20),
//                 child: Text(
//                   timeAgo(widget.entity.createdAt),
//                   style: TextStyle(
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ),
//             Row(
//               children: [
//                 Text(
//                   likeCount.toString(),
//                   style: TextStyle(
//                     color: Colors.grey,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: _toggleLike,
//                   icon: Icon(
//                     isLiked ? Icons.favorite : Icons.favorite_border,
//                     color: isLiked ? Colors.red : Colors.red[300],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         SizedBox(height: 5),
//         GestureDetector(
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DetailQuestions(widget.entity),
//             ),
//           ),
//           child: Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: randomColor,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: Colors.grey[300]!,
//                 width: 0.5,
//               ),
//             ),
//             padding: EdgeInsets.all(10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 2),
//                 Text(
//                   textPreview(widget.entity.content, 80),
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
