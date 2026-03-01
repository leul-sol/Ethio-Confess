import 'package:flutter/material.dart';
import '../core/error/app_error.dart';

class InlineError extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;

  const InlineError({
    Key? key,
    required this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error.message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4169E1),
              ),
            ),
        ],
      ),
    );
  }
} 