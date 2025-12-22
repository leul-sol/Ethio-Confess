// import 'package:flutter/material.dart';

// class FeatureSpotlight extends StatelessWidget {
//   final Widget child;
//   final String title;
//   final String description;
//   final VoidCallback onNext;
//   final VoidCallback? onSkip;
//   final bool isLastStep;
//   final Color overlayColor;
//   final Color textColor;
//   final EdgeInsets contentPadding;

//   const FeatureSpotlight({
//     Key? key,
//     required this.child,
//     required this.title,
//     required this.description,
//     required this.onNext,
//     this.onSkip,
//     this.isLastStep = false,
//     this.overlayColor = Colors.black54,
//     this.textColor = Colors.white,
//     this.contentPadding = const EdgeInsets.all(20.0),
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       type: MaterialType.transparency,
//       child: Stack(
//         children: [
//           // Semi-transparent overlay that covers the entire screen
//           Positioned.fill(
//             child: Container(
//               color: overlayColor,
//             ),
//           ),

//           // The actual UI element we want to highlight
//           Positioned.fill(
//             child: Center(
//               child: child,
//             ),
//           ),

//           // Tooltip content at the bottom of the screen
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: Container(
//               padding: contentPadding,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(16),
//                   topRight: Radius.circular(16),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     spreadRadius: 5,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF3A6FE5),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     description,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       if (onSkip != null)
//                         TextButton(
//                           onPressed: onSkip,
//                           child: const Text(
//                             'Skip Tour',
//                             style: TextStyle(
//                               color: Colors.grey,
//                               fontSize: 16,
//                             ),
//                           ),
//                         )
//                       else
//                         const SizedBox.shrink(),
//                       ElevatedButton(
//                         onPressed: onNext,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF3A6FE5),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 24,
//                             vertical: 12,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text(
//                           isLastStep ? 'Got it' : 'Next',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
