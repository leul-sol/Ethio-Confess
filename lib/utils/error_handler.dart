// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:graphql_flutter/graphql_flutter.dart';

// enum ErrorType { network, server, unknown }

// class AppError {
//   final String message;
//   final ErrorType errorType;

//   AppError(this.message, this.errorType);
// }

// class ErrorHandle {
//   static void logError(AppError error) {
//     print('Error occurred: ${error.message}');
//   }

//   static String getErrorMessage(AppError error) {
//     switch (error.errorType) {
//       case ErrorType.network:
//         return 'Unable to connect to the internet. Please check your network connection.';
//       case ErrorType.server:
//         return 'There was an issue with the server. Please try again later.';
//       default:
//         return 'An unknown error occurred. Please try again.';
//     }
//   }

//   // Show a toast for network issues
//   static void showErrorSnackBar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 4),
//       ),
//     );
//   }
// }

// class NetworkExceptions {
//   static String getDioException(error) {
//     if (error is SocketException) {
//       return 'No internet connection';
//     } else if (error is HttpException) {
//       return 'HTTP error occurred';
//     } else if (error is FormatException) {
//       return 'Invalid response format';
//     } else if (error is TimeoutException) {
//       return 'Request timed out';
//     } else if (error is OperationException) {
//       if (error.graphqlErrors.isNotEmpty) {
//         return error.graphqlErrors.first.message;
//       }
//       return 'GraphQL error occurred';
//     } else {
//       return 'Unexpected error occurred';
//     }
//   }

//   static bool isNoInternetError(error) {
//     return error is SocketException;
//   }

//   static bool isTimeoutError(error) {
//     return error is TimeoutException;
//   }
// }

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

enum ErrorType {
  network,
  server,
  authentication, // Added authentication error type
  unknown
}

class AppError {
  final String message;
  final ErrorType errorType;

  const AppError(this.message, this.errorType);

  @override
  String toString() => message;

  // Helper method to create authentication errors
  static AppError unauthorized(String message) {
    return AppError(message, ErrorType.authentication);
  }

  // Helper method to create network errors
  static AppError network(String message) {
    return AppError(message, ErrorType.network);
  }

  // Helper method to create server errors
  static AppError server(String message) {
    return AppError(message, ErrorType.server);
  }

  // Helper method to create unknown errors
  static AppError unknown(String message) {
    return AppError(message, ErrorType.unknown);
  }
}

class ErrorHandle {
  static void logError(AppError error) {
    print('Error occurred: ${error.message} (Type: ${error.errorType})');
  }

  static String getErrorMessage(AppError error) {
    switch (error.errorType) {
      case ErrorType.network:
        return 'Unable to connect to the internet. Please check your network connection.';
      case ErrorType.server:
        return 'There was an issue with the server. Please try again later.';
      case ErrorType.authentication:
        return error.message.isNotEmpty
            ? error.message
            : 'Authentication error. Please login again.';
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }

  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // New method to handle authentication errors specifically
  static void handleAuthError(
      BuildContext context, String message, VoidCallback onRetry) {
    showErrorSnackBar(
      context,
      message,
      action: SnackBarAction(
        label: 'Login',
        textColor: Colors.white,
        onPressed: onRetry,
      ),
    );
  }
}

class NetworkExceptions {
  static String getDioException(error) {
    if (error is SocketException) {
      return 'No internet connection';
    } else if (error is HttpException) {
      return 'HTTP error occurred';
    } else if (error is FormatException) {
      return 'Invalid response format';
    } else if (error is TimeoutException) {
      return 'Request timed out';
    } else if (error is OperationException) {
      if (error.graphqlErrors.isNotEmpty) {
        return error.graphqlErrors.first.message;
      }
      if (error.linkException is HttpLinkServerException) {
        final statusCode = (error.linkException as HttpLinkServerException)
            .response
            .statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return 'Authentication error';
        }
      }
      return 'GraphQL error occurred';
    } else {
      return 'Unexpected error occurred';
    }
  }

  static ErrorType getErrorType(error) {
    if (error is SocketException) {
      return ErrorType.network;
    } else if (error is TimeoutException) {
      return ErrorType.network;
    } else if (error is OperationException) {
      if (error.linkException is HttpLinkServerException) {
        final statusCode = (error.linkException as HttpLinkServerException)
            .response
            .statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return ErrorType.authentication;
        }
        return ErrorType.server;
      }
      return ErrorType.server;
    }
    return ErrorType.unknown;
  }

  static bool isNoInternetError(error) {
    return error is SocketException;
  }

  static bool isTimeoutError(error) {
    return error is TimeoutException;
  }

  static bool isAuthenticationError(error) {
    if (error is OperationException &&
        error.linkException is HttpLinkServerException) {
      final statusCode =
          (error.linkException as HttpLinkServerException).response.statusCode;
      return statusCode == 401 || statusCode == 403;
    }
    return false;
  }
}

// Example usage in a widget:
/*
try {
  // Your API call
} catch (e) {
  final errorType = NetworkExceptions.getErrorType(e);
  final errorMessage = NetworkExceptions.getDioException(e);
  final appError = AppError(errorMessage, errorType);
  
  ErrorHandle.logError(appError);
  
  if (errorType == ErrorType.authentication) {
    ErrorHandle.handleAuthError(
      context, 
      errorMessage,
      () => Navigator.pushReplacementNamed(context, '/login'),
    );
  } else {
    ErrorHandle.showErrorSnackBar(context, ErrorHandle.getErrorMessage(appError));
  }
}
*/
