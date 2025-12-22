import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/error/app_error.dart';
import '../core/error/error_handler_service.dart';
import '../providers/error_provider.dart';
import 'error_page.dart';
import 'inline_error.dart';

class ErrorHandlerWidget extends ConsumerWidget {
  final Widget child;
  final bool showFullPageError;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorHandlerWidget({
    Key? key,
    required this.child,
    this.showFullPageError = true,
    this.onRetry,
    this.retryText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AppError?>(errorProvider, (previous, current) {
      if (current != null) {
        ErrorHandlerService.handleErrorDisplay(
          context,
          current,
          onRetry: onRetry,
          retryText: retryText,
        );
        ref.read(errorProvider.notifier).clearError();
      }
    });

    return child;
  }
}

class ErrorDisplayWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showFullPage;

  const ErrorDisplayWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.retryText,
    this.showFullPage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showFullPage) {
      return ErrorPage(
        error: error,
        onRetry: onRetry,
        retryText: retryText,
      );
    }

    return InlineError(
      error: error,
      onRetry: onRetry,
    );
  }
} 