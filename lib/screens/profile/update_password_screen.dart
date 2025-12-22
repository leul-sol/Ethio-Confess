import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/biography_providers.dart';
import '../../widgets/input_text_field.dart';
import '../../widgets/auth_button.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';

final currentPasswordVisibilityProvider = StateProvider<bool>((ref) => false);
final newPasswordVisibilityProvider = StateProvider<bool>((ref) => false);
final confirmPasswordVisibilityProvider = StateProvider<bool>((ref) => false);

class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() =>
      _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final _oldPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _oldPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider);

    final userProfileAsync = ref.watch(userProfileProvider(userId!));
    print(userProfileAsync);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update password'),
      ),
      body: userProfileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
        data: (userData) {
          // Update controllers with latest data
          _emailController.text = userData['email'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _emailController,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Enter your full name",
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // CustomInputTextField(
                  //   label: "Email",
                  //   hint: "Enter your full name",
                  //   controller: _emailController,
                  // ),
                  const SizedBox(height: 16),
                  CustomInputTextField(
                    label: "Current Password",
                    hint: "Enter your current password",
                    controller: _oldPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    visibilityProvider: currentPasswordVisibilityProvider,
                  ),
                  const SizedBox(height: 16),
                  CustomInputTextField(
                    label: "New Password",
                    hint: "Enter your new password",
                    controller: _newPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    visibilityProvider: newPasswordVisibilityProvider,
                  ),
                  const SizedBox(height: 16),
                  CustomInputTextField(
                    label: "Confirm New Password",
                    hint: "Confirm your new password",
                    controller: _confirmNewPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    visibilityProvider: confirmPasswordVisibilityProvider,
                  ),
                  const SizedBox(height: 40),
                  Consumer(
                    builder: (context, ref, child) {
                      final profileState = ref.watch(profileStateProvider);

                      return AuthButton(
                        text: profileState.maybeWhen(
                          loading: () => "Updating...",
                          orElse: () => "Update Password",
                        ),
                        onPressed: () {
                          final callback =
                              profileState.maybeWhen<VoidCallback?>(
                            loading: () => null,
                            orElse: () => () {
                              if (_oldPasswordController.text.isEmpty ||
                                  _newPasswordController.text.isEmpty ||
                                  _confirmNewPasswordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill in all fields'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Validate password match
                              if (_newPasswordController.text !=
                                  _confirmNewPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Passwords do not match'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              ref
                                  .read(profileStateProvider.notifier)
                                  .updateUserPassword(
                                    email: _emailController.text,
                                    currentPassword: _oldPasswordController.text,
                                    newPassword: _newPasswordController.text,
                                  )
                                  .then((_) {
                                final status = ref.read(profileStateProvider);
                                status.maybeWhen(
                                  success: (message) {
                                    final _ = ref.refresh(userProfileProvider(userId));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  error: (message) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                  orElse: () {},
                                );
                              });
                            },
                          );

                          if (callback != null) {
                            callback();
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
