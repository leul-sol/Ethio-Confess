import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metsnagna/providers/biography_providers.dart';
// import 'package:metsnagna/services/biography_page_services.dart';
import 'package:metsnagna/models/popular_entity.dart';
import 'package:metsnagna/providers/user_provider.dart';

import '../../providers/auth_provider.dart';

class PostScreen extends ConsumerStatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final TextEditingController contentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  bool _hasAttemptedToPostTooShortContent = false;

  int get _characterCount => contentController.text.length;
  static const int _minCharacters = 500;

  @override
  void initState() {
    super.initState();
  }

  final TextAlign _textAlignment = TextAlign.left;

  @override
  Widget build(BuildContext context) {
    final bool showUnderLimitError = _hasAttemptedToPostTooShortContent && _characterCount < _minCharacters;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Biography',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF4A90E2).withAlpha(70), width: 1),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: contentController,
                      focusNode: _focusNode,
                      maxLines: null,
                      expands: true,
                      textAlign: _textAlignment,
                      decoration: InputDecoration(
                        hintText: 'Type here ...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onChanged: (text) {
                        setState(() {
                          if (_hasAttemptedToPostTooShortContent && _characterCount >= _minCharacters) {
                            _hasAttemptedToPostTooShortContent = false;
                          }
                        });
                      },
                    ),
                  ),
                  // Custom counter with padding
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_characterCount >= _minCharacters ? _characterCount : (_minCharacters - _characterCount)}',
                        style: TextStyle(
                          color: _characterCount >= _minCharacters ? Colors.green : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showUnderLimitError)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Biography must be at least 500 characters to post.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          // Post Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: !_isLoading ? () => handlePost() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handlePost() async {
    if (_characterCount < _minCharacters) {
      setState(() {
        _hasAttemptedToPostTooShortContent = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final content = contentController.text.trim();
    final params = {
      'content': content,
    };

    try {
      final success = await ref.read(addBiographyProvider(params).future);

      if (success) {
        // Optimistically add the new biography to the list
        final userState = ref.read(userProvider);
        final username = userState.user?.username ?? 'Unknown';
        final newBio = PopularEntity(
          id: null,
          category: null,
          createdAt: DateTime.now().toIso8601String(),
          content: content,
          username: username,
          likeCount: 0,
        );
        ref.read(allbiographyProvider.notifier).addBiographyOptimistically(newBio);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Biography added successfully"),
            backgroundColor: Colors.green,
          ),
        );
        final userId = ref.read(userIdProvider);
        ref.invalidate(userBiographiesProvider(userId!));
        ref.invalidate(allbiographyProvider);
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.pop(context, true);
      } else {
        // If the operation returned false, verify if it was actually created
        final content = params['content'] as String;
        final wasActuallyCreated = await ref.read(verifyBiographyCreationProvider(content).future);
        final userId = ref.read(userIdProvider);
        ref.invalidate(userBiographiesProvider(userId!));
        ref.invalidate(allbiographyProvider);
        await Future.delayed(const Duration(milliseconds: 300));
        if (wasActuallyCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Biography added successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to add biography. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      // On error, verify if the biography was actually created
      final wasActuallyCreated = await ref.read(verifyBiographyCreationProvider(content).future);
      final userId = ref.read(userIdProvider);
      ref.invalidate(userBiographiesProvider(userId!));
      ref.invalidate(allbiographyProvider);
      await Future.delayed(const Duration(milliseconds: 300));
      if (wasActuallyCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Biography added successfully despite network issues!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Network error occurred. Please try again."),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => handlePost(),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
