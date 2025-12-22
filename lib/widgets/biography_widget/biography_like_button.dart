// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ethioconfess/providers/biography_like_provider.dart';
// import 'package:ethioconfess/providers/auth_provider.dart';
// import 'package:ethioconfess/utils/auth_utils.dart';

// class BiographyLikeButton extends ConsumerStatefulWidget {
//   final String biographyId;
//   final int initialLikeCount;
//   final double iconSize;

//   const BiographyLikeButton({
//     Key? key,
//     required this.biographyId,
//     required this.initialLikeCount,
//     this.iconSize = 20,
//   }) : super(key: key);

//   @override
//   ConsumerState<BiographyLikeButton> createState() =>
//       _BiographyLikeButtonState();
// }

// class _BiographyLikeButtonState extends ConsumerState<BiographyLikeButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );

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

//     // Initialize like count
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref
//           .read(biographyLikeCountProvider.notifier)
//           .initializeLikeCount(widget.biographyId, widget.initialLikeCount);

//       // Initialize like status
//       _initializeLikeStatus();
//     });
//   }

//   Future<void> _initializeLikeStatus() async {
//     final userId = ref.read(userIdProvider);
//     if (userId != null) {
//       await ref
//           .read(biographyLikeProvider.notifier)
//           .initializeLike(widget.biographyId);
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLiked =
//         ref.watch(biographyLikeProvider).containsKey(widget.biographyId)
//             ? ref.watch(biographyLikeProvider)[widget.biographyId] ?? false
//             : false;

//     final likeCount =
//         ref.watch(biographyLikeCountProvider).containsKey(widget.biographyId)
//             ? ref.watch(biographyLikeCountProvider)[widget.biographyId] ??
//                 widget.initialLikeCount
//             : widget.initialLikeCount;

//     return Row(
//       children: [
//         GestureDetector(
//           onTap: () async {
//             // Check authentication before allowing like action
//             if (!await handleProtectedAction(
//               context,
//               action: ProtectedAction.like,
//               message: 'Please sign in to like biographies',
//             )) {
//               return;
//             }

//             _controller.forward(from: 0.0);
//             ref
//                 .read(biographyLikeProvider.notifier)
//                 .toggleLike(widget.biographyId, likeCount);
//           },
//           child: ScaleTransition(
//             scale: _scaleAnimation,
//             child: Icon(
//               isLiked ? Icons.favorite : Icons.favorite_border_sharp,
//               color: Colors.red,
//               size: widget.iconSize,
//             ),
//           ),
//         ),
//         const SizedBox(width: 4),
//         Text(
//           likeCount.toString(),
//           style: TextStyle(
//             fontSize: widget.iconSize * 0.7,
//             color: Colors.black54,
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethioconfess/providers/biography_like_provider.dart';
import 'package:ethioconfess/providers/auth_provider.dart';
import 'package:ethioconfess/utils/auth_utils.dart';

class BiographyLikeButton extends ConsumerStatefulWidget {
  final String biographyId;
  final int initialLikeCount;
  final double iconSize;

  const BiographyLikeButton({
    Key? key,
    required this.biographyId,
    required this.initialLikeCount,
    this.iconSize = 20,
  }) : super(key: key);

  @override
  ConsumerState<BiographyLikeButton> createState() =>
      _BiographyLikeButtonState();
}

class _BiographyLikeButtonState extends ConsumerState<BiographyLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 50,
      ),
    ]).animate(_controller);

    // Initialize like count
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(biographyLikeCountProvider.notifier)
          .initializeLikeCount(widget.biographyId, widget.initialLikeCount);

      // Initialize like status
      _initializeLikeStatus();
    });
  }

  Future<void> _initializeLikeStatus() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      await ref
          .read(biographyLikeProvider.notifier)
          .initializeLike(widget.biographyId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLiked =
        ref.watch(biographyLikeProvider).containsKey(widget.biographyId)
            ? ref.watch(biographyLikeProvider)[widget.biographyId] ?? false
            : false;

    final likeCount =
        ref.watch(biographyLikeCountProvider).containsKey(widget.biographyId)
            ? ref.watch(biographyLikeCountProvider)[widget.biographyId] ??
                widget.initialLikeCount
            : widget.initialLikeCount;

    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            // Check authentication before allowing like action
            if (!await handleProtectedAction(
              context,
              action: ProtectedAction.like,
              message: 'Please sign in to like biographies',
            )) {
              return;
            }

            _controller.forward(from: 0.0);

            // Get current count for the API call
            final currentCount =
                ref.read(biographyLikeCountProvider)[widget.biographyId] ??
                    widget.initialLikeCount;

            // This will update both like status and count in a single operation
            ref
                .read(biographyLikeProvider.notifier)
                .toggleLike(widget.biographyId, currentCount);
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border_sharp,
              color: Colors.red,
              size: widget.iconSize,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          likeCount.toString(),
          style: TextStyle(
            fontSize: widget.iconSize * 0.7,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
