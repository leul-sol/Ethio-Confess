import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vent_provider.dart';
import '../../providers/chat_settings_provider.dart';
import '../../core/error/error_handler_service.dart';
import '../../utils/auth_utils.dart';
import '../../widgets/message_action_dialog.dart';
import '../../utils/avatar_utils.dart';

import 'vent_replay.dart';

class VentDetail extends ConsumerWidget {
  final Map<String, dynamic> vent;
  final Function(Map<String, dynamic>) onEditReply;
  final Function(Map<String, dynamic>)? onReplyToReply;
  final Function(Map<String, dynamic>)? onStartChat;

  const VentDetail({
    Key? key,
    required this.vent,
    required this.onEditReply,
    this.onReplyToReply,
    this.onStartChat,
  }) : super(key: key);

  void _showReplyOptions(BuildContext context, WidgetRef ref, Map<String, dynamic> reply, BuildContext buttonContext) {
    final userId = ref.read(userIdProvider);
    final isOwnReply = userId != null && reply['user']['id'] == userId;

    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(const Offset(0, 20), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(const Offset(0, 20)), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    
    showMenu(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      items: [
        PopupMenuItem(
          height: 40,
          child: const Row(
            children: [
              Icon(Icons.edit, size: 20, color: Colors.black87),
              SizedBox(width: 12),
              Text('Edit'),
            ],
          ),
          onTap: () {
            onEditReply(reply);
          },
        ),
        PopupMenuItem(
          height: 40,
          child: const Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () async {
            try {
              final success = await ref.read(deleteReplyProvider(reply['id']).future);
              if (success) {
                // Refresh both the vent list and vent detail
                ref.invalidate(ventProvider);
                ref.invalidate(ventDetailProvider(vent['id']));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ErrorHandlerService.handleError(e).message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String createdAt = vent['created_at'];
    DateTime dateTime = DateTime.parse(createdAt);
    String formattedDate = DateFormat('yMMMd').format(dateTime);
    final userId = ref.watch(userIdProvider);
    final isVentOwner = userId == vent['user']['id'];
    final allowChat = ref.watch(chatSettingsProvider);
    final ventOwnerAllowChat = vent['user']['allow_chat'] ?? true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                      final String? profileImage = vent['user']?['profile_image'];
                      print("profileImage: $profileImage");

                      final ImageProvider? avatarImage = AvatarUtils.getProfileImage(profileImage);
                      print("avatarImage: $avatarImage");
                      print("Will show person icon: ${avatarImage == null}");
                      return CircleAvatar(
                        radius: 16,
                        backgroundImage: avatarImage,
                        backgroundColor: Colors.grey.shade200,
                        child: avatarImage == null
                            ? const Icon(
                                Icons.person,
                                size: 20,
                                color: Colors.grey,
                              )
                            : null,
                      );
                    },
                  ),
                ],
              ),
              Text(
                '• $formattedDate',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            vent['content'] ?? '',
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 36),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.repeat, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${vent['ventreplies'].length}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    vent['ventreplies'].length == 1
                        ? 'Response'
                        : 'Responses',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Builder(
                builder: (context) {
                  if (!isVentOwner && onStartChat != null) {
                    if (ventOwnerAllowChat) {
                      return GestureDetector(
                        onTap: () async {
                          if (await handleProtectedAction(
                            context,
                            action: ProtectedAction.comment,
                            message: 'Please sign in to start a chat',
                          )) {
                            onStartChat!(vent);
                          }
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF4169E1)),
                            SizedBox(width: 4),
                            Text(
                              'Start Chat',
                              style: TextStyle(
                                color: Color(0xFF4169E1),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Row(
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'Chat Disabled',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          VentReplies(
            ventReplies: vent['ventreplies'],
            onReplyOptions: (reply, context) => _showReplyOptions(context, ref, reply, context),
            currentUserId: userId,
            onReplyToReply: onReplyToReply,
            ventOwnerId: vent['user']['id'],
          ),
        ],
      ),
    );
  }
}
