import 'package:flutter/material.dart';

class ScreenOne extends StatelessWidget {
  const ScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/youssef-naddam-iJ2IG8ckCpA-unsplash.jpg'),
          fit: BoxFit.cover, // Makes the image cover the entire container
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black54, // Darker at the top
                  Colors.transparent, // Transparent in the middle
                  Colors.black54, // Darker at the bottom
                ],
              ),
            ),
          ),
          // Text content
          const Align(
            alignment:
                Alignment.bottomLeft, // Aligns the text to the bottom-left
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 120.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Keeps the content compact
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align text to the start (left)
                children: const [
                  Text(
                    'Welcome to Vent Ethiopia',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16), // Space between the two texts
                  Text(
                    'Share your thoughts, be heard, and connect with a supportive community.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
