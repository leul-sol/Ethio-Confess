import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethioconfess/screens/auth/signin_screen.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/input_text_field.dart';
import '../guest/guest_screen.dart';


final passwordVisibilityProvider = StateProvider<bool>((ref) => false);
final confirmPasswordVisibilityProvider = StateProvider<bool>((ref) => false);

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final usernameController = TextEditingController();
    final phoneController = TextEditingController();

    // Listen to auth state changes
    ref.listen(authStateProvider, (previous, current) {
      current.maybeWhen(
        signupSuccess: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SigninScreen()),
          );
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
          // ref.read(authStateProvider.notifier).clearError();
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
                        // Clear any error state before navigating
                        ref.read(authStateProvider.notifier).clearError();
                        // Prefer returning to the root (AuthWrapper renders Guest)
                        final route = ModalRoute.of(context);
                        if (route != null && route.isFirst) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const GuestScreen(),
                            ),
                          );
                        } else {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        }
                      },
                      child: const Text("Continue as a Guest")),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "Welcome to\nVent Ethiopia",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4169E1),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We're happy to have you.",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 48),
              CustomInputTextField(
                label: "Username",
                hint: "Enter your username",
                controller: usernameController,
                maxLength: 16, // Limit to 16 characters
                showCounter: false, // Hide the character counter
              ),
              const SizedBox(height: 24),
              CustomInputTextField(
                label: "Email",
                hint: "Your email",
                controller: emailController,
              ),
              const SizedBox(height: 24),
              CustomInputTextField(
                label: "Phone Number",
                hint: "Your phone number",
                controller: phoneController,
              ),
              const SizedBox(height: 24),
              CustomInputTextField(
                controller: passwordController,
                hint: "********",
                label: "Password",
                isPassword: true,
                visibilityProvider: passwordVisibilityProvider,
              ),
              const SizedBox(height: 24),
              CustomInputTextField(
                controller: confirmPasswordController,
                hint: "Confirm Password",
                label: "Confirm Password",
                isPassword: true,
                visibilityProvider: confirmPasswordVisibilityProvider,
              ),
              const SizedBox(height: 32),
              Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authStateProvider);

                  return AuthButton(
                      text: authState.maybeWhen(
                        loading: () => "Signing up...",
                        orElse: () => "Sign up",
                      ),
                      onPressed: () {
                        final callback = authState.maybeWhen<VoidCallback?>(
                          loading: () => null,
                          orElse: () => () {
                            // Validate inputs
                            if (usernameController.text.isEmpty ||
                                emailController.text.isEmpty ||
                                phoneController.text.isEmpty ||
                                passwordController.text.isEmpty ||
                                confirmPasswordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill in all fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Validate email format
                            final emailRegExp = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );
                            if (!emailRegExp.hasMatch(emailController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please enter a valid email address'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Validate phone number format
                            final phoneRegExp = RegExp(
                                r'^\+?[0-9]{10,15}$'); // Allows optional "+" and 10-15 digits
                            if (!phoneRegExp.hasMatch(phoneController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Please enter a valid phone number'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            // Validate password match
                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passwords do not match'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Debug: Print signup data
                            print('=== SIGNUP DEBUG START ===');
                            print('Email: ${emailController.text}');
                            print('Username: ${usernameController.text}');
                            print('Phone: ${phoneController.text}');
                            print('Password length: ${passwordController.text.length}');
                            print('=== SIGNUP DEBUG END ===');
                            
                            // Call signup
                            ref.read(authStateProvider.notifier).signup(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  phoneNo: phoneController.text,
                                  username: usernameController.text,
                                );
                          },
                        );
                        if (callback != null) {
                          callback();
                        }
                      });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Login",
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
