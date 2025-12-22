import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_button.dart';
import 'otp_screen.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    ref.listen(authStateProvider, (previous, current) {
      current.maybeWhen(
        resetCodeSent: (_) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OtpScreen(
                    email: _emailController.text,
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
            // On back from reset flow, prefer returning to sign-in, not stacking guest/auth
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
                  'Reset Your Password',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E232C),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter your email adress below\nand we'll send you a link with instructions",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF8391A1),
                    height: 1.5,
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
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1E232C),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter Email Address',
                      hintStyle: TextStyle(
                        color: Color(0xFF8391A1),
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.email_outlined,
                          color: Color(0xFF8391A1),
                          size: 20,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
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
                        orElse: () => "Send Code",
                      ),
                      onPressed: () {
                        final callback = authState.maybeWhen<VoidCallback?>(
                          loading: () => null,
                          orElse: () => () {
                            final email = _emailController.text.trim();

                            if (email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill in all fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (!isValidEmail(email)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please enter a valid email address'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            ref
                                .read(authStateProvider.notifier)
                                .requestResetCode(email);
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
