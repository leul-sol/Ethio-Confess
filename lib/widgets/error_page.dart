import 'package:flutter/material.dart';
import '../core/error/app_error.dart';

class ErrorPage extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final String? retryText;
  final Widget? customIcon;

  const ErrorPage({
    Key? key,
    required this.error,
    this.onRetry,
    this.retryText,
    this.customIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customIcon ?? _getErrorIcon(error.errorType),
            const SizedBox(height: 16),
            Text(
              _getErrorTitle(error.errorType),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryText ?? 'Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getErrorIcon(ErrorType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case ErrorType.network:
        iconData = Icons.wifi_off;
        color = Colors.orange;
        break;
      case ErrorType.server:
        iconData = Icons.error_outline;
        color = Colors.red;
        break;
      case ErrorType.authentication:
        iconData = Icons.lock_outline;
        color = Colors.purple;
        break;
      case ErrorType.validation:
        iconData = Icons.warning_amber;
        color = Colors.amber;
        break;
      case ErrorType.notFound:
        iconData = Icons.search_off;
        color = Colors.blue;
        break;
      case ErrorType.unknown:
        iconData = Icons.help_outline;
        color = Colors.grey;
        break;
    }

    return Icon(
      iconData,
      size: 64,
      color: color,
    );
  }

  String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'No Internet Connection';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.authentication:
        return 'Authentication Error';
      case ErrorType.validation:
        return 'Validation Error';
      case ErrorType.notFound:
        return 'Not Found';
      case ErrorType.unknown:
        return 'Something Went Wrong';
    }
  }
} 