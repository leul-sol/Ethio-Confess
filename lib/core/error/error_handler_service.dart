import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'app_error.dart';
import 'error_display_type.dart';
import '../../widgets/error_page.dart';

class ErrorHandlerService {
  static AppError handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }

    if (error is OperationException) {
      return _handleGraphQLError(error);
    }

    if (error is SocketException) {
      return AppError.network('No internet connection', error, stackTrace);
    }

    if (error is TimeoutException) {
      return AppError.network('Request timed out', error, stackTrace);
    }

    return AppError.unknown(
      error.toString(),
      error,
      stackTrace,
    );
  }

  static AppError _handleGraphQLError(OperationException error) {
    if (error.graphqlErrors.isNotEmpty) {
      final firstError = error.graphqlErrors.first;
      final rawMessage = firstError.message;
      final friendlyMessage = _toFriendlyMessage(rawMessage);
      return AppError.server(friendlyMessage, error);
    }

    if (error.linkException is HttpLinkServerException) {
      final httpError = error.linkException as HttpLinkServerException;
      final statusCode = httpError.response.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        return AppError.authentication('Authentication failed', error);
      }

      if (statusCode == 404) {
        return AppError.notFound('Resource not found', error);
      }

      return AppError.server('Server error: $statusCode', error);
    }

    return AppError.unknown('An unexpected error occurred', error);
  }

  /// Converts technical GraphQL/backend messages into user-friendly text.
  static String _toFriendlyMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('not found in type') ||
        lower.contains('query_root') ||
        lower.contains('mutation_root') ||
        lower.contains('field') && lower.contains('doesn\'t exist')) {
      return 'Something went wrong loading this. Please try again.';
    }
    if (lower.contains('authorization') || lower.contains('jwt') || lower.contains('cookie')) {
      return 'Please sign in again to continue.';
    }
    if (lower.contains('permission') || lower.contains('forbidden')) {
      return 'You don\'t have access to do this.';
    }
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return 'Request took too long. Please try again.';
    }
    return raw;
  }

  static ErrorDisplayType getDisplayType(AppError error) {
    switch (error.errorType) {
      case ErrorType.network:
        return ErrorDisplayType.fullPage;
      case ErrorType.server:
        return ErrorDisplayType.fullPage;
      case ErrorType.authentication:
        return ErrorDisplayType.snackbar;
      case ErrorType.validation:
        return ErrorDisplayType.inline;
      case ErrorType.notFound:
        return ErrorDisplayType.fullPage;
      case ErrorType.unknown:
        return ErrorDisplayType.fullPage;
    }
  }

  static void handleErrorDisplay(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
    String? retryText,
  }) {
    final displayType = getDisplayType(error);

    switch (displayType) {
      case ErrorDisplayType.snackbar:
        _showSnackBar(context, error);
        break;
      case ErrorDisplayType.fullPage:
        _showErrorPage(context, error, onRetry, retryText);
        break;
      case ErrorDisplayType.inline:
        // Handle inline errors (usually handled by form widgets)
        break;
      case ErrorDisplayType.dialog:
        _showErrorDialog(context, error, onRetry);
        break;
      case ErrorDisplayType.none:
        // Handle silently
        break;
    }
  }

  static void _showSnackBar(BuildContext context, AppError error) {
    final snackBar = SnackBar(
      content: Text(error.message),
      backgroundColor: _getErrorColor(error.errorType),
      duration: const Duration(seconds: 4),
      action: _getErrorAction(context, error),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void _showErrorPage(
    BuildContext context,
    AppError error,
    VoidCallback? onRetry,
    String? retryText,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
          ),
          body: ErrorPage(
            error: error,
            onRetry: onRetry,
            retryText: retryText,
          ),
        ),
      ),
    );
  }

  static void _showErrorDialog(
    BuildContext context,
    AppError error,
    VoidCallback? onRetry,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getErrorTitle(error.errorType)),
        content: Text(error.message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Try Again'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.authentication:
        return Colors.purple;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.notFound:
        return Colors.blue;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }

  static String _getErrorTitle(ErrorType type) {
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

  static SnackBarAction? _getErrorAction(BuildContext context, AppError error) {
    switch (error.errorType) {
      case ErrorType.authentication:
        return SnackBarAction(
          label: 'Login',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        );
      case ErrorType.network:
        return SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            // Implement retry logic
          },
        );
      default:
        return null;
    }
  }
} 