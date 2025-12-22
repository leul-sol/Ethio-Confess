// import 'package:flutter/material.dart';
// import 'package:ethioconfess/widgets/splash_widget/feature_spotlight.dart';

// import '../../utils/app_preference.dart';

// class WalkthroughStep {
//   final GlobalKey targetKey;
//   final String title;
//   final String description;
//   final bool canSkip;

//   WalkthroughStep({
//     required this.targetKey,
//     required this.title,
//     required this.description,
//     this.canSkip = true,
//   });
// }

// class WalkthroughOverlay {
//   final List<WalkthroughStep> steps;
//   final BuildContext context;
//   final String walkthroughId;
//   final VoidCallback? onComplete;

//   int _currentStepIndex = 0;
//   OverlayEntry? _currentOverlay;

//   WalkthroughOverlay({
//     required this.steps,
//     required this.context,
//     required this.walkthroughId,
//     this.onComplete,
//   });

//   // Start the walkthrough if it hasn't been completed before
//   Future<void> start() async {
//     final isCompleted =
//         await AppPreferences.isWalkthroughCompleted(walkthroughId);

//     if (isCompleted || steps.isEmpty) {
//       onComplete?.call();
//       return;
//     }

//     _showCurrentStep();
//   }

//   // Show the current step
//   void _showCurrentStep() {
//     _removeCurrentOverlay();

//     if (_currentStepIndex >= steps.length) {
//       _completeWalkthrough();
//       return;
//     }

//     final step = steps[_currentStepIndex];
//     final RenderBox? renderBox =
//         step.targetKey.currentContext?.findRenderObject() as RenderBox?;

//     if (renderBox == null) {
//       // If we can't find the target element, skip to the next step
//       _nextStep();
//       return;
//     }

//     final Offset position = renderBox.localToGlobal(Offset.zero);
//     final Size size = renderBox.size;

//     _currentOverlay = OverlayEntry(
//       builder: (context) => Stack(
//         children: [
//           // Full screen overlay
//           Positioned.fill(
//             child: FeatureSpotlight(
//               child: Positioned(
//                 left: position.dx,
//                 top: position.dy,
//                 width: size.width,
//                 height: size.height,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.white, width: 2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//               title: step.title,
//               description: step.description,
//               isLastStep: _currentStepIndex == steps.length - 1,
//               onNext: _nextStep,
//               onSkip: step.canSkip ? _completeWalkthrough : null,
//             ),
//           ),
//         ],
//       ),
//     );

//     Overlay.of(context).insert(_currentOverlay!);
//   }

//   // Move to the next step
//   void _nextStep() {
//     _currentStepIndex++;
//     _showCurrentStep();
//   }

//   // Complete the walkthrough
//   Future<void> _completeWalkthrough() async {
//     _removeCurrentOverlay();
//     await AppPreferences.markWalkthroughCompleted(walkthroughId);
//     onComplete?.call();
//   }

//   // Remove the current overlay
//   void _removeCurrentOverlay() {
//     _currentOverlay?.remove();
//     _currentOverlay = null;
//   }

//   // Dispose resources
//   void dispose() {
//     _removeCurrentOverlay();
//   }
// }
