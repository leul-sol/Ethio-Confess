import 'package:flutter/material.dart';
import '../utils/error_handler.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final AppError error;

  const ErrorDisplayWidget({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String errorMessage = ErrorHandle.getErrorMessage(error);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 120),
          Image.asset(
            "assets/images/no-results.png",
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 24),
          // const SizedBox(height: 20),
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          // const SizedBox(height: 20),
          const SizedBox(height: 16),
          const Text(
            'Pull down to refresh',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
