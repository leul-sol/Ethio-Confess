import 'package:flutter/material.dart';
import '../utils/error_handler.dart';
import 'app_error_widget.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;

  const ErrorDisplayWidget({
    Key? key,
    required this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String errorMessage = ErrorHandle.getErrorMessage(error);
    return AppErrorWidget(
      message: errorMessage,
      subtitle: 'Something went wrong. Please try again.',
      onRetry: onRetry,
    );
  }
}
