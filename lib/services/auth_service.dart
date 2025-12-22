import 'dart:async';
import 'dart:io';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../graphql/auth_mutation.dart';
import '../models/auth_state.dart';

import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

class AuthService {
  final GraphQLClient _client;

  AuthService(this._client);

  Future<AuthState> signup({
    required String email,
    required String password,
    required String phoneNo,
    required String username,
  }) async {
    try {
      print('=== AUTH SERVICE SIGNUP START ===');
      print('Email: $email');
      print('Username: $username');
      print('Phone: $phoneNo');
      print('Password length: ${password.length}');
      
      print('Preparing GraphQL mutation...');
      final result = await _client.mutate(
        MutationOptions(
          document: gql(signupMutation),
          variables: {
            'email': email,
            'password': password,
            'phoneNo': phoneNo,
            'username': username,
          },
        ),
      );
      print('GraphQL mutation completed');
      print('Has data: ${result.data != null}');
      print('Has exception: ${result.hasException}');
      
      if (result.hasException) {
        print('GraphQL errors:');
        for (var error in result.exception!.graphqlErrors) {
          print('  - ${error.message}');
        }
      }

      print('Calling _handleMutationResult...');
      return _handleMutationResult(
        result,
        onData: (data) {
          print('Processing signup response data...');
          final String? message = data['signup']['message'];
          print('Signup message: ${message ?? 'null'}');
          if (message == null) {
            print('No message in response, returning error');
            return const AuthState.error('Invalid response from server');
          }
          print('Signup successful, returning success state');
          return const AuthState.signupSuccess('User created successfully');
        },
      );
    } on OperationException catch (e) {
      print('=== AUTH SERVICE SIGNUP OPERATION EXCEPTION ===');
      print('OperationException: $e');
      return _handleGraphQLError(e);
    } on SocketException {
      print('=== AUTH SERVICE SIGNUP SOCKET EXCEPTION ===');
      print('SocketException: No internet connection');
      return const AuthState.error('No internet connection');
    } on TimeoutException {
      print('=== AUTH SERVICE SIGNUP TIMEOUT EXCEPTION ===');
      print('TimeoutException: Request timed out');
      return const AuthState.error('Request timed out. Please try again');
    } catch (e) {
      print('=== AUTH SERVICE SIGNUP UNEXPECTED ERROR ===');
      print('Unexpected error: $e');
      return _handleUnexpectedError(e);
    }
  }

  Future<AuthState> login(String email, String password) async {
    try {
      developer.log('Attempting login with email: $email');
      
      final result = await _client.mutate(
        MutationOptions(
          document: gql(loginMutation),
          variables: {
            'usernameOremail': email,
            'password': password,
          },
        ),
      );

      developer.log('Login response received: ${result.data != null ? 'Has data' : 'No data'}');
      if (result.hasException) {
        developer.log('Login error details:', error: result.exception);
        if (result.exception?.linkException != null) {
          developer.log('Network/Link error:', error: result.exception?.linkException);
        }
        if (result.exception?.graphqlErrors.isNotEmpty == true) {
          for (var error in result.exception!.graphqlErrors) {
            developer.log('GraphQL error: ${error.message}');
          }
        }
      }

      return _handleMutationResult(
        result,
        onData: (data) {
          final String? token = data['login']['accessToken'];
          if (token == null) {
            developer.log('Login failed: No access token in response');
            return const AuthState.error('Invalid response from server');
          }

          try {
            // Decode JWT token to get user ID
            final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
            final String? userId = decodedToken['https://hasura.io/jwt/claims']
                ?['x-hasura-user-id'];

            if (userId == null) {
              developer.log('Login failed: Invalid token format - no user ID found');
              return const AuthState.error('Invalid token format');
            }

            developer.log('Login successful for user ID: $userId');
            return AuthState.authenticated(token: token, userId: userId);
          } catch (e) {
            developer.log('Error processing authentication token', error: e);
            return const AuthState.error(
                'Error processing authentication token');
          }
        },
      );
    } on OperationException catch (e) {
      developer.log('GraphQL OperationException during login:', error: e);
      if (e.linkException != null) {
        developer.log('Link exception details:', error: e.linkException);
      }
      return _handleGraphQLError(e);
    } on SocketException catch (e) {
      developer.log('Network error during login:', error: e);
      return const AuthState.error('No internet connection');
    } on TimeoutException catch (e) {
      developer.log('Login request timed out:', error: e);
      return const AuthState.error('Request timed out. Please try again');
    } catch (e) {
      developer.log('Unexpected error during login:', error: e);
      return _handleUnexpectedError(e);
    }
  }

  Future<AuthState> getResetCode(String email) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(getResetCodeMutation),
          variables: {'email': email},
        ),
      );

      // Log the full GraphQL result
      developer.log('getResetCode QueryResult: ${result.data}');
      if (result.hasException) {
        developer.log('getResetCode Exception: ${result.exception}');
        if (result.exception is OperationException) {
          final opException = result.exception as OperationException;
          developer.log('getResetCode OperationException originalException: ${opException.linkException?.originalException}');
          if (opException.graphqlErrors != null) {
            for (var error in opException.graphqlErrors!) {
              developer.log('getResetCode GraphQL Error: ${error.message}');
            }
          }
        }
      }

      return _handleMutationResult(
        result,
        onData: (data) {
          final String? message = data['getResetCode']['message'];
          if (message == null) {
            return const AuthState.error('Invalid response from server');
          }
          return AuthState.resetCodeSent(message);
        },
      );
    } on OperationException catch (e) {
      return _handleGraphQLError(e);
    } on SocketException {
      return const AuthState.error('No internet connection');
    } on TimeoutException {
      return const AuthState.error('Request timed out. Please try again');
    } catch (e) {
      return _handleUnexpectedError(e);
    }
  }

  Future<AuthState> verifyCode(String code, String email) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(verifyCodeMutation),
          variables: {'code': code, 'email': email},
        ),
      );
      // Log the full GraphQL result for verifyCode
      developer.log('verifyCode QueryResult: ${result.data}');
      if (result.hasException) {
        developer.log('verifyCode Exception: ${result.exception}');
        if (result.exception is OperationException) {
          final opException = result.exception as OperationException;
          developer.log('verifyCode OperationException originalException: ${opException.linkException?.originalException}');
          if (opException.graphqlErrors != null) {
            for (var error in opException.graphqlErrors!) {
              developer.log('verifyCode GraphQL Error: ${error.message}');
            }
          }
        }
      }
      print(code);
      print(email);

      return _handleMutationResult(
        result,
        onData: (data) {
          final String? message = data['verifyCode']['message'];
          if (message == null) {
            return const AuthState.error('Invalid response from server');
          }
          return AuthState.codeVerified(message);
        },
      );
    } on OperationException catch (e) {
      return _handleGraphQLError(e);
    } on SocketException {
      return const AuthState.error('No internet connection');
    } on TimeoutException {
      return const AuthState.error('Request timed out. Please try again');
    } catch (e) {
      return _handleUnexpectedError(e);
    }
  }

  Future<AuthState> resetPassword(
      String code, String email, String newPassword) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(resetPasswordMutation),
          variables: {'code': code, 'email': email, 'newPassword': newPassword},
        ),
      );
      print(code);
      print(email);

      return _handleMutationResult(
        result,
        onData: (data) {
          final String? message = data['resetPassword']['message'];
          if (message == null) {
            return const AuthState.error('Invalid response from server');
          }
          return AuthState.passwordResetSuccess(message);
        },
      );
    } on OperationException catch (e) {
      return _handleGraphQLError(e);
    } on SocketException {
      return const AuthState.error('No internet connection');
    } on TimeoutException {
      return const AuthState.error('Request timed out. Please try again');
    } catch (e) {
      return _handleUnexpectedError(e);
    }
  }

  AuthState _handleMutationResult<T>(
    QueryResult result, {
    required AuthState Function(Map<String, dynamic> data) onData,
  }) {
    if (result.hasException) {
      return _handleGraphQLError(result.exception!);
    }

    if (result.data == null) {
      return const AuthState.error('No data received from server');
    }

    try {
      return onData(result.data!);
    } catch (e) {
      return const AuthState.error('Error processing server response');
    }
  }

  AuthState _handleGraphQLError(OperationException exception) {
    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      return AuthState.error(_getReadableErrorMessage(error.message));
    }

    if (exception.linkException != null) {
      final linkException = exception.linkException!;

      if (linkException is HttpLinkServerException) {
        switch (linkException.response.statusCode) {
          case 401:
            return const AuthState.error('Session expired. Please login again');
          case 403:
            return const AuthState.error('Access denied');
          case 404:
            return const AuthState.error('Service not found');
          case >= 500:
            return const AuthState.error(
                'Server error. Please try again later');
          default:
            return const AuthState.error('An error occurred. Please try again');
        }
      }

      if (linkException is ServerException) {
        return const AuthState.error('Unable to reach server');
      }
    }

    return const AuthState.error('An unexpected error occurred');
  }

  AuthState _handleUnexpectedError(Object error) {
    return const AuthState.error('An unexpected error occurred');
  }

  String _getReadableErrorMessage(String message) {
    switch (message.toLowerCase()) {
      case 'invalid_credentials':
      case 'incorrect credential':
        return 'Invalid email or password';
      case 'email_already_exists':
        return 'This email is already registered';
      case 'username_taken':
        return 'This username is already taken';
      case 'error sending email':
        return 'Failed to send reset email. Please try again or contact support.';
      case 'weak_password':
        return 'Password is too weak. Please use a stronger password';
      default:
        return message;
    }
  }
}
