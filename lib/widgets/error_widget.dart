import 'package:flutter/material.dart';

class ErrorIconWidget extends StatelessWidget {
  final String message;

  const ErrorIconWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: Colors.red,
          size: 48, // Adjust size as needed
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 