import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../providers/chat_settings_provider.dart';
import '../../utils/auth_utils.dart';
import '../../utils/avatar_utils.dart';

class VentReplies extends StatefulWidget {
  final List<dynamic> ventReplies;
  final Function(Map<String, dynamic>, BuildContext) onReplyOptions;
  final String? currentUserId;
  final Function(Map<String, dynamic>)? onReplyToReply;
  final String? ventOwnerId;

  const VentReplies({
    Key? key,
    required this.ventReplies,
    required this.onReplyOptions,
    required this.currentUserId,
    this.onReplyToReply,
    this.ventOwnerId,
  }) : super(key: key);

  @override
  State<VentReplies> createState() => _VentRepliesState();
}

class _VentRepliesState extends State<VentReplies> {
  @override
  Widget build(BuildContext context) {
    // Filter only top-level replies (those without parent_id)
    final topLevelReplies = widget.ventReplies.where((reply) => reply['parent_id'] == null).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topLevelReplies.length,
      itemBuilder: (context, index) {
        return VentReplyItem(
          reply: topLevelReplies[index],
          allReplies: widget.ventReplies,
          onReplyOptions: widget.onReplyOptions,
          currentUserId: widget.currentUserId,
          onReplyToReply: widget.onReplyToReply,
          depth: 0,
          ventOwnerId: widget.ventOwnerId!,
        );
      },
    );
  }
}

class VentReplyItem extends ConsumerStatefulWidget {
  final Map<String, dynamic> reply;
  final List<dynamic> allReplies;
  final Function(Map<String, dynamic>, BuildContext) onReplyOptions;
  final String? currentUserId;
  final Function(Map<String, dynamic>)? onReplyToReply;
  final int depth;
  final String ventOwnerId;
  final String? parentUsername;
  final String? parentReplyPreview;

  const VentReplyItem({
    Key? key,
    required this.reply,
    required this.allReplies,
    required this.onReplyOptions,
    this.currentUserId,
    this.onReplyToReply,
    this.depth = 0,
    required this.ventOwnerId,
    this.parentUsername,
    this.parentReplyPreview,
  }) : super(key: key);

  @override
  ConsumerState<VentReplyItem> createState() => _VentReplyItemState();
}

class _VentReplyItemState extends ConsumerState<VentReplyItem> {
  bool _expanded = false;

  // Helper function to count all replies recursively
  int _countAllReplies(List<dynamic> replies) {
    int count = 0;
    for (var reply in replies) {
      count++; // Count this reply
      final children = (reply['children'] as List<dynamic>?) ?? [];
      if (children.isNotEmpty) {
        count += _countAllReplies(children); // Recursively count children
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final reply = widget.reply;
    final allReplies = widget.allReplies;
    final onReplyOptions = widget.onReplyOptions;
    final currentUserId = widget.currentUserId;
    final onReplyToReply = widget.onReplyToReply;
    final depth = widget.depth;
    final ventOwnerId = widget.ventOwnerId;
    final parentUsername = widget.parentUsername;
    final parentReplyPreview = widget.parentReplyPreview;

    // final allowChat = ref.watch(chatSettingsProvider);
    final user = reply['user'] ?? {};
    final isCurrentUserReply = currentUserId == user['id'];
    final replyAuthorAllowChat = user['allow_chat'] ?? true;
    final createdAt = DateTime.tryParse(reply['created_at'] ?? '') ?? DateTime.now();
    final formattedDate = DateFormat('MMM d, y').format(createdAt);
    String? previewText;
    if ((parentReplyPreview ?? '').isNotEmpty) {
      final source = parentReplyPreview ?? '';
      previewText = (source.length > 10)
          ? source.substring(0, 10) + '...'
          : source;
    }
    final children = (reply['children'] as List<dynamic>?) ?? [];
    final hasChildren = children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth == 1 ? 16.0 : 0.0, bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Builder(
                              builder: (context) {
                                final profileImage = user['profile_image'];
                                final avatarImage = AvatarUtils.getProfileImage(profileImage);
                                print("VentReply - profileImage: $profileImage");
                                print("VentReply - avatarImage: $avatarImage");
                                print("VentReply - Will show person icon: ${avatarImage == null}");
                                return CircleAvatar(
                                  radius: 12,
                                  backgroundImage: avatarImage,
                                  backgroundColor: Colors.grey.shade200,
                                  child: avatarImage == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey,
                                        )
                                      : null,
                                );
                              },
                            ),
                            if (depth > 1 && parentUsername != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  previewText != null
                                      ? 'Replying to a comment: "$previewText"'
                                      : 'Replying to a comment',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          
                          ],
                        ),
                        if (isCurrentUserReply)
                          Builder(
                            builder: (context) => GestureDetector(
                              onTap: () => onReplyOptions(reply, context),
                              child: const Icon(
                                Icons.more_horiz,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reply['reply'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (onReplyToReply != null)
                          GestureDetector(
                            onTap: () async {
                              if (await handleProtectedAction(
                                context,
                                action: ProtectedAction.comment,
                                message: 'Please sign in to reply to comments',
                              )) {
                                onReplyToReply(reply);
                              }
                            },
                            child: const Text(
                              'Reply',
                              style: TextStyle(
                                color: Color(0xFF4169E1),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (currentUserId != null && 
                            user['id'] != currentUserId)
                          replyAuthorAllowChat
                              ? GestureDetector(
                                  onTap: () async {
                                    if (await handleProtectedAction(
                                      context,
                                      action: ProtectedAction.comment,
                                      message: 'Please sign in to start a chat',
                                    )) {
                                      if (user['id'] != null && 
                                          user['username'] != null) {
                                        Navigator.pushNamed(
                                          context,
                                          '/chat',
                                          arguments: {
                                            'participantId': user['id'],
                                            'participantName': user['username'],
                                          },
                                        );
                                      }
                                    }
                                  },
                                  child: const Icon(
                                    Icons.chat_outlined,
                                    color: Color(0xFF4169E1),
                                    size: 20,
                                  ),
                                )
                              : const Row(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Chat Disabled',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                      ],
                    ),
                    if (hasChildren && depth == 0)
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Row(
                            children: [
                              Icon(
                                _expanded ? Icons.expand_less : Icons.expand_more,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _expanded
                                    ? 'Hide replies'
                                    : 'Show replies (${_countAllReplies(children)})',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (hasChildren && ((depth == 0 && _expanded) || depth != 0))
                      ...List.generate(
                        children.length,
                        (i) => VentReplyItem(
                          reply: children[i],
                          allReplies: allReplies,
                          onReplyOptions: onReplyOptions,
                          currentUserId: currentUserId,
                          onReplyToReply: onReplyToReply,
                          depth: depth + 1,
                          ventOwnerId: ventOwnerId,
                          parentUsername: user['username'],
                          parentReplyPreview: reply['reply'],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
