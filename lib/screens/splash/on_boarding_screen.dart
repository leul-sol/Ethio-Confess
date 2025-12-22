import 'package:flutter/material.dart';
import 'package:metsnagna/screens/splash/screen_one.dart';
import 'package:metsnagna/screens/splash/screen_three.dart';
import 'package:metsnagna/screens/splash/screen_two.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:metsnagna/screens/auth/signin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controller to keep track of which page we are on
  final PageController _controller = PageController();

  // Keep track of whether we are on the last page
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.85; // 85% of screen width
    
    return Scaffold(
      body: Stack(
        children: [
          // PageView for onboarding screens
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = index == 2; // Update if on the last page
              });
            },
            children: const [
              ScreenOne(),
              ScreenTwo(),
              ScreenThree(),
            ],
          ),

          // Skip button at the top-right corner
          Positioned(
            top: 50,
            right: 25,
            child: GestureDetector(
              onTap: () {
                _controller.jumpToPage(2); // Skip to the last page
              },
              child: const Text(
                'skip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Dots and Button at the bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dot indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: CustomizableEffect(
                    activeDotDecoration: DotDecoration(
                      width: 24, // Longer active dot
                      height: 8,
                      color: Colors.white, // Active dot color
                      borderRadius: BorderRadius.circular(4),
                    ),
                    dotDecoration: DotDecoration(
                      width: 8, // Shorter inactive dots
                      height: 8,
                      color:
                          Colors.white.withOpacity(0.5), // Inactive dots color
                      borderRadius: BorderRadius.circular(4),
                    ),
                    spacing: 8, // Space between dots
                  ),
                ),

                const SizedBox(height: 20), // Space between dots and button

                // Next or Done button
                SizedBox(
                  width: buttonWidth,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (onLastPage) {
                        // Mark onboarding as completed and navigate to sign in
                        widget.onComplete();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SigninScreen()),
                        );
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A6FE5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      onLastPage ? 'Done' : 'Next',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
