import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metsnagna/screens/auth/new_password_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/auth_button.dart';

final otpControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

class OtpScreen extends ConsumerWidget {
  final String email;

  const OtpScreen({required this.email, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpController = ref.watch(otpControllerProvider);

    // Set system overlay style.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    ref.listen(authStateProvider, (previous, current) {
      current.maybeWhen(
        codeVerified: (_) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NewPasswordScreen(
                    code: otpController.text.trim(),
                    email: email,
                  )));
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
        leading: BackButton(
          onPressed: () {
            // Clear any error state before navigating back
            ref.read(authStateProvider.notifier).clearError();
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 72),
                const Center(
                  child: Image(
                    image: AssetImage("assets/images/resetPassword.png"),
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Send OTP',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E232C),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter your otp below",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF8391A1),
                    height: 1.5,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 4,
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 60,
                      fieldWidth: 60,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      activeColor: const Color(0xFF4B7FD6),
                      inactiveColor: const Color(0xFFE8ECF4),
                      selectedColor: const Color(0xFF4B7FD6),
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    onCompleted: (value) {
                      // Handle OTP completion here using Riverpod if needed
                    },
                    onChanged: (value) {
                      // Handle OTP changes here if needed
                    },
                  ),
                ),
                const SizedBox(height: 48),
                Consumer(
                  builder: (context, ref, child) {
                    final authState = ref.watch(authStateProvider);

                    return AuthButton(
                      text: authState.maybeWhen(
                        loading: () => "Loading...",
                        orElse: () => "Verify OTP",
                      ),
                      onPressed: () {
                        final callback = authState.maybeWhen<VoidCallback?>(
                          loading: () => null,
                          orElse: () => () {
                            if (otpController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill in the OTP field'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Pass both the email and code to verifyCode.
                            ref
                                .read(authStateProvider.notifier)
                                .verifyCode(otpController.text.trim(), email);
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
