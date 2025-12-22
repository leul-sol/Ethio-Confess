// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../providers/auth_provider.dart';
// import 'dart:developer' as developer;
// import '../../widgets/auth_button.dart';
// import '../../widgets/input_text_field.dart';
// import '../auth/password_reset_screen.dart';
// import '../guest/guest_screen.dart';
// import 'signup_screen.dart';

// final passwordVisibilityProvider = StateProvider<bool>((ref) => false);

// class SigninScreen extends ConsumerWidget {
//   final VoidCallback? onRestart;
//   const SigninScreen({super.key, this.onRestart});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final emailController = TextEditingController();
//     final passwordController = TextEditingController();

//     ref.listen(authStateProvider, (previous, current) {
//       // Get the error message from previous and current states.
//       final prevError = previous?.maybeWhen(
//         error: (message) => message,
//         orElse: () => '',
//       );
//       final currError = current.maybeWhen(
//         error: (message) => message,
//         orElse: () => '',
//       );

//       // Only show SnackBar if a new error message appears.
//       if (currError.isNotEmpty && currError != prevError) {
//         developer.log('Login Error: $currError');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(currError),
//             backgroundColor: Colors.red,
//           ),
//         );
//         // Clear error after showing the SnackBar.
//         // ref.read(authStateProvider.notifier).clearError();
//       }

//       // Handle successful authentication.
//       current.maybeWhen(
//         authenticated: (token, _) {
//           // Return to root (AuthWrapper will render MainScreen based on auth state)
//           Navigator.of(context).popUntil((route) => route.isFirst);
//           // Restart ProviderScope if provided (optional)
//           if (onRestart != null) {
//             onRestart!();
//           }
//         },
//         orElse: () {},
//       );
//     });

//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding:
//               const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                       onPressed: () {
//                         // Clear any error state before navigating
//                         ref.read(authStateProvider.notifier).clearError();
//                         // Prefer returning to the root (AuthWrapper will render Guest)
//                         final route = ModalRoute.of(context);
//                         if (route != null && route.isFirst) {
//                           Navigator.of(context).pushReplacement(
//                             MaterialPageRoute(
//                               builder: (context) => const GuestScreen(),
//                             ),
//                           );
//                         } else {
//                           Navigator.of(context).popUntil((r) => r.isFirst);
//                         }
//                       },
//                       child: const Text("Continue as a Guest")),
//                 ],
//               ),
//               const SizedBox(height: 30),
//               const Text(
//                 "Let's Sign You in",
//                 style: TextStyle(
//                   fontSize: 40,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF4169E1),
//                   height: 1.2,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 "Welcome back.\nYou've been missed!",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w500,
//                   height: 1.2,
//                 ),
//               ),
//               const SizedBox(height: 48),
//               CustomInputTextField(
//                 label: "Email or Username",
//                 hint: "Your email or username",
//                 controller: emailController,
//               ),
//               const SizedBox(height: 24),
//               CustomInputTextField(
//                 controller: passwordController,
//                 hint: "********",
//                 label: "Password",
//                 isPassword: true,
//                 visibilityProvider: passwordVisibilityProvider,
//               ),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const ResetPasswordScreen(),
//                       ),
//                     );
//                   },
//                   style: TextButton.styleFrom(
//                     foregroundColor: const Color(0xFF4169E1),
//                   ),
//                   child: const Text(
//                     "Forgot your password?",
//                     style: TextStyle(fontSize: 14),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               Consumer(
//                 builder: (context, ref, child) {
//                   final authState = ref.watch(authStateProvider);

//                   return AuthButton(
//                     text: authState.maybeWhen(
//                       loading: () => "Loading...",
//                       orElse: () => "Log in",
//                     ),
//                     onPressed: () {
//                       final callback = authState.maybeWhen<VoidCallback?>(
//                         loading: () => null,
//                         orElse: () => () {
//                           if (emailController.text.isEmpty ||
//                               passwordController.text.isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Please fill in all fields'),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                             return;
//                           }

//                           developer.log('Attempting login with email: \\${emailController.text}');
//                           ref.read(authStateProvider.notifier).login(
//                                 emailController.text.trim(),
//                                 passwordController.text,
//                               );
//                         },
//                       );

//                       if (callback != null) {
//                         callback();
//                       }
//                     },
//                   );
//                 },
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     "Don't have an account? ",
//                     style: TextStyle(
//                       color: Colors.black87,
//                       fontSize: 14,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const SignupScreen(),
//                         ),
//                       );
//                     },
//                     child: const Text(
//                       "Register",
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'dart:developer' as developer;
import '../../widgets/auth_button.dart';
import '../../widgets/input_text_field.dart';
import '../auth/password_reset_screen.dart';
import '../guest/guest_screen.dart';
import '../main_screen.dart';
import 'signup_screen.dart';

final passwordVisibilityProvider = StateProvider<bool>((ref) => false);

class SigninScreen extends ConsumerWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    ref.listen(authStateProvider, (previous, current) {
      // Get the error message from previous and current states.
      final prevError = previous?.maybeWhen(
        error: (message) => message,
        orElse: () => '',
      );
      final currError = current.maybeWhen(
        error: (message) => message,
        orElse: () => '',
      );

      // Only show SnackBar if a new error message appears.
      if (currError.isNotEmpty && currError != prevError) {
        developer.log('Login Error: $currError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currError),
            backgroundColor: Colors.red,
          ),
        );
        // Clear error after showing the SnackBar.
        // ref.read(authStateProvider.notifier).clearError();
      }

      // Handle successful authentication.
      current.maybeWhen(
        authenticated: (token, _) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        },
        orElse: () {},
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GuestScreen(),
                          ),
                        );
                      },
                      child: const Text("Continue as a Guest")),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "Let's Sign You in",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4169E1),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Welcome back.\nYou've been missed!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 48),
              CustomInputTextField(
                label: "Email or Username",
                hint: "Your email or username",
                controller: emailController,
              ),
              const SizedBox(height: 24),
              CustomInputTextField(
                controller: passwordController,
                hint: "********",
                label: "Password",
                isPassword: true,
                visibilityProvider: passwordVisibilityProvider,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResetPasswordScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4169E1),
                  ),
                  child: const Text(
                    "Forgot your password?",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authStateProvider);

                  return AuthButton(
                    text: authState.maybeWhen(
                      loading: () => "Loading...",
                      orElse: () => "Log in",
                    ),
                    onPressed: () {
                      final callback = authState.maybeWhen<VoidCallback?>(
                        loading: () => null,
                        orElse: () => () {
                          if (emailController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          developer.log('Attempting login with email: \\${emailController.text}');
                          ref.read(authStateProvider.notifier).login(
                                emailController.text.trim(),
                                passwordController.text,
                              );
                        },
                      );

                      if (callback != null) {
                        callback();
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}