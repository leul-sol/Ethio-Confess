import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double horizontalPadding;
  final double verticalPadding;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF3A6FE5), // Default button color
    this.textColor = Colors.white, // Default text color
    this.horizontalPadding = 100.0,
    this.verticalPadding = 15.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 16),
      ),
    );
  }
}
