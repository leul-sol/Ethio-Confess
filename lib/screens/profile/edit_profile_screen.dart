import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/biography_providers.dart';
import '../../widgets/input_text_field.dart';
import '../../widgets/auth_button.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/avatar_picker.dart';
import '../../utils/avatar_utils.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _profile_image;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    print('[EditProfileScreen] userIdProvider: ' + userId.toString());

    final userProfileAsync = ref.watch(userProfileProvider(userId!));
    print('[EditProfileScreen] userProfileProvider called with userId: ' + userId.toString());
    print('[EditProfileScreen] userProfileAsync: ' + userProfileAsync.toString());

    return Scaffold(

      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      
      body: userProfileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error:  ' + error.toString()),
        ),
        data: (userData) {
          print('[EditProfileScreen] userProfileProvider data: ' + userData.toString());
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_nameController.text != (userData['username'] ?? '')) {
              _nameController.text = userData['username'] ?? '';
            }
            if (_emailController.text != (userData['email'] ?? '')) {
              _emailController.text = userData['email'] ?? '';
            }
            if (_profile_image == null) {
              setState(() {
                _profile_image = userData['profile_image'];
              });
              print('=== EDIT PROFILE IMAGE DEBUG ===');
              print('Setting profile image from userData: ${userData['profile_image']}');
              print('Current _profile_image: $_profile_image');
              print('=== EDIT PROFILE IMAGE DEBUG END ===');
            }
          });
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AvatarPicker(
                    selectedAvatarUrl: _profile_image,
                    onAvatarChanged: (avatarUrl) {
                      setState(() {
                        _profile_image = avatarUrl;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomInputTextField(
                    label: "Full Name",
                    hint: "Enter your full name",
                    controller: _nameController,
                    maxLength: 16, // Limit to 16 characters
                    showCounter: false, // Hide the character counter
                  ),
                  const SizedBox(height: 16),
                  CustomInputTextField(
                    label: "Email",
                    hint: "Enter your email",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 40),
                  Consumer(
                    builder: (context, ref, child) {
                      final profileState = ref.watch(profileStateProvider);
                      
                      print('=== PROFILE STATE DEBUG ===');
                      print('Profile state: $profileState');

                      return AuthButton(
                        text: profileState.maybeWhen(
                          loading: () => "Updating...",
                          orElse: () => "Update Profile",
                        ),
                        onPressed: () {
                          final callback =
                              profileState.maybeWhen<VoidCallback?>(
                            loading: () => null,
                            orElse: () => () {
                              if (_nameController.text.isEmpty ||
                                  _emailController.text.isEmpty) {
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
                              if (!emailRegExp
                                  .hasMatch(_emailController.text)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please enter a valid email address'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              print('=== EDIT PROFILE UPDATE BUTTON PRESSED ===');
                              print('User ID: $userId');
                              print('Name: ${_nameController.text}');
                              print('Email: ${_emailController.text}');
                              print('Profile Image: ${_profile_image ?? 'null'}');
                              
                              ref
                                  .read(profileStateProvider.notifier)
                                  .updateProfile(
                                      userId: userId,
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      profile_image: _profile_image)
                                  .then((_) {
                                print('Profile update completed successfully');
                                // Refresh the user profile data
                                ref.refresh(userProfileProvider(userId));
                                print('User profile provider refreshed');

                                // Navigate back to profile screen
                                Navigator.of(context).pop();
                                print('Navigated back to profile screen');
                              }).catchError((error) {
                                print('Profile update failed: $error');
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
