import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/auth/signin_screen.dart';
import '../providers/auth_provider.dart';

enum ProtectedAction {
  create,
  like,
  comment,
}

Future<bool> handleProtectedAction(BuildContext context,
    {ProtectedAction action = ProtectedAction.create, String? message}) async {
  // Get the ProviderContainer
  final container = ProviderScope.containerOf(context);
  final authState = container.read(authStateProvider);

  // Check if user is authenticated using the actual auth state
  final bool isAuthenticated = authState.maybeWhen(
    authenticated: (_, __) => true,
    orElse: () => false,
  );

  if (!isAuthenticated) {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Sign in Required'),
        content: Text(message ?? 'Please sign in to continue'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        actions: [
          // Sign In Button
          // Cancel Button
           TextButton(
            onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,

              ),
              child: const Text('Cancel'),
            ),

              TextButton(
              onPressed: () {
              Navigator.pop(context, false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SigninScreen(),
                ),
              );
            },
              style: TextButton.styleFrom(
                foregroundColor:const Color(0xFF4169E1), // Blue b
              ),
              child: const Text('Signin'),
            ),
        
        ],
      ),
    );
    return result ?? false;
  }
  return true;
}
