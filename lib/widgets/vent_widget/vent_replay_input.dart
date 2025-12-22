import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../../providers/reply_provider.dart';
import '../../utils/auth_utils.dart';
// import '../../providers/auth_provider.dart';
import '../../utils/avatar_utils.dart';

class ReplyInput extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String ventId;
  final VoidCallback onReplySubmitted;
  final Map<String, dynamic>? editingReply;
  final VoidCallback? onEditCancel;
  final String? parentId;
  final Map<String, dynamic>? replyingToUser;
  final ScrollController? scrollController;

  const ReplyInput({
    Key? key,
    required this.controller,
    required this.ventId,
    required this.onReplySubmitted,
    this.editingReply,
    this.onEditCancel,
    this.parentId,
    this.replyingToUser,
    this.scrollController,
  }) : super(key: key);

  @override
  ConsumerState<ReplyInput> createState() => _ReplyInputState();
}

class _ReplyInputState extends ConsumerState<ReplyInput> {
  bool _isInputEnabled = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.editingReply != null) {
      print('Editing reply: ${widget.editingReply}');
      print('Reply text: ${widget.editingReply!['reply']}');
      widget.controller.text = widget.editingReply!['reply'] ?? '';
      _isInputEnabled = true;
      // Schedule focus after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
    
    // Listen for focus changes to handle keyboard behavior
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.scrollController != null) {
        // Scroll to bottom when input is focused
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.scrollController!.hasClients) {
            widget.scrollController!.animateTo(
              widget.scrollController!.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(ReplyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingReply != null && oldWidget.editingReply == null) {
      widget.controller.text = widget.editingReply!['reply'] ?? '';
      _isInputEnabled = true;
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final replyState = ref.watch(replyNotifierProvider);
    final replyNotifier = ref.read(replyNotifierProvider.notifier);

    bool isTextNotEmpty = widget.controller.text.trim().isNotEmpty;
    
    // Get screen dimensions for responsive design
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
    
    // Calculate appropriate padding based on screen size and keyboard
    final bottomPadding = isKeyboardVisible 
        ? 8.0 
        : screenHeight < 700 
            ? 16.0 
            : 24.0;

    return Container(
      // Add bottom padding to account for system UI and screen size
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: bottomPadding,
      ),
      // Add background color to ensure visibility
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.editingReply != null || widget.parentId != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                widget.controller.clear();
                widget.onEditCancel?.call();
              },
            ),
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight < 600 ? 100 : 120,
                minHeight: 48, // Ensure minimum touch target
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.replyingToUser != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundImage: AvatarUtils.getProfileImage(widget.replyingToUser?['profile_image']),
                        backgroundColor: Colors.grey.shade200,
                        child: AvatarUtils.getProfileImage(widget.replyingToUser?['profile_image']) == null
                            ? const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                  ],
                  Expanded(
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        readOnly: !_isInputEnabled,
                        maxLines: null,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: widget.editingReply != null 
                              ? 'Edit reply' 
                              : widget.parentId != null 
                                  ? 'Reply to comment' 
                                  : 'Reply here',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        ),
                        onTap: () async {
                          if (!await handleProtectedAction(
                            context,
                            action: ProtectedAction.comment,
                            message: 'Please sign in to reply to vents',
                          )) {
                            setState(() {
                              _isInputEnabled = false;
                            });
                            FocusScope.of(context).unfocus();
                          } else {
                            setState(() {
                              _isInputEnabled = true;
                            });
                          }
                        },
                        onChanged: (text) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 8),
                    child: Material(
                      color: isTextNotEmpty ? Colors.blue : Colors.grey,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: replyState.isLoading
                            ? null
                            : () async {
                                final replyContent = widget.controller.text.trim();
                                if (replyContent.isEmpty) return;

                                print('Starting reply update from UI...');
                                print('Editing reply: ${widget.editingReply}');
                                print('Reply content: $replyContent');

                                if (widget.editingReply != null) {
                                  print('Attempting to update reply...');
                                  try {
                                    await replyNotifier.updateReply(
                                      widget.editingReply!['id'],
                                      replyContent,
                                    );
                                    print('Update request completed');
                                  } catch (e) {
                                    print('Error during update: $e');
                                  }
                                } else {
                                  print('Adding new reply...');
                                  // final userId = ref.read(userIdProvider);
                                  String contentToSend = replyContent;
                                  await replyNotifier.addReply({
                                    "vent_id": widget.ventId,
                                    'reply': contentToSend,
                                    // 'user_id': userId,
                                    if (widget.parentId != null) 'parent_id': widget.parentId,
                                  });
                                }

                                replyState.maybeWhen(
                                  error: (message) {
                                    print('Error state received: $message');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );
                                  },
                                  orElse: () {
                                    print('Success state received');
                                    widget.controller.clear();
                                    widget.onReplySubmitted();
                                  },
                                );
                              },
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: replyState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  widget.editingReply != null
                                      ? Icons.check
                                      : Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
