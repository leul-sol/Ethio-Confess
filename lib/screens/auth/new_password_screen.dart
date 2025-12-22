import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethioconfess/screens/auth/signin_screen.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/auth_button.dart';

class NewPasswordScreen extends ConsumerStatefulWidget {
  final String code;
  final String email;

  const NewPasswordScreen({
    Key? key,
    required this.code,
    required this.email,
  }) : super(key: key);

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system bar style.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    ref.listen(authStateProvider, (previous, current) {
      current.maybeWhen(
        passwordResetSuccess: (_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SigninScreen(),
            ),
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
      // backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 72),
                const Center(
                  child: Image(
                    image: AssetImage("assets/images/newPasswords.png"),
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Enter New Password',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E232C),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set Complex passwords to protect',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF8391A1),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1E232C),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter new password',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8391A1),
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.lock_outline,
                          color: Color(0xFF8391A1),
                          size: 20,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFF8391A1),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_confirmPasswordVisible,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1E232C),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Re-Enter password',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8391A1),
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.lock_outline,
                          color: Color(0xFF8391A1),
                          size: 20,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: IconButton(
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFF8391A1),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                        orElse: () => "Reset Password",
                      ),
                      onPressed: () {
                        final callback = authState.maybeWhen<VoidCallback?>(
                          loading: () => null,
                          orElse: () => () {
                            final password = _passwordController.text.trim();
                            final confirmPassword =
                                _confirmPasswordController.text.trim();

                            if (password.isEmpty || confirmPassword.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill in all fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            if (password != confirmPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passwords do not match'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Pass both the email and code to verifyCode.
                            ref.read(authStateProvider.notifier).resetPassword(
                                  widget.code,
                                  widget.email,
                                  password,
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
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1E232C),
                        letterSpacing: -0.2,
                      ),
                      children: [
                        TextSpan(text: 'Need Help'),
                        TextSpan(text: ' | '),
                        TextSpan(text: 'FAQ'),
                        TextSpan(text: ' | '),
                        TextSpan(text: 'Terms Of use'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
