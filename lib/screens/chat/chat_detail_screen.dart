// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'dart:developer' as developer;
// import 'dart:async';
// import 'package:graphql_flutter/graphql_flutter.dart';
// import 'dart:async'; // Import for TimeoutException
// import '../../models/chat_message.dart';
// import '../../models/conversation.dart';
// import '../../services/chat_service.dart';
// import '../../providers/auth_provider.dart';
// import '../../widgets/edit_message_dialog.dart';
// import '../../widgets/message_action_widget.dart';
// import '../../widgets/message_action_dialog.dart';
// import 'package:sticky_headers/sticky_headers.dart';

// class ChatDetailScreen extends ConsumerStatefulWidget {
//   final Conversation conversation;

//   const ChatDetailScreen({
//     Key? key,
//     required this.conversation,
//   }) : super(key: key);

//   @override
//   ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
// }

// class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final FocusNode _messageFocusNode = FocusNode();
//   String? _chatId;
//   List<ChatMessage> _messages = [];
//   bool _isLoading = true;
//   String? _error;
//   StreamSubscription? _messageSubscription;
//   bool _isSending = false;
//   ChatMessage? _editingMessage; // Track which message is being edited
//   int _previousMessageCount = 0; // Track previous message count

//   @override
//   void initState() {
//     super.initState();
//     _messageController.addListener(_onMessageTextChanged);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _initializeChat();
//   }

//   void _onMessageTextChanged() {
//     setState(() {}); // Rebuild to update send button state
//   }

//   @override
//   void dispose() {
//     _messageController.removeListener(_onMessageTextChanged);
//     _messageController.dispose();
//     _scrollController.dispose();
//     _messageFocusNode.dispose();
//     _messageSubscription?.cancel();
//     super.dispose();
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   Future<void> _initializeChat() async {
//     developer.log('[_initializeChat] Called');
//     try {
//       if (mounted) {
//         setState(() {
//           _error = null;
//         });
//       }
//       final currentUserId = ref.watch(currentUserIdProvider);
//       developer.log('[_initializeChat] currentUserId: '
//           '\u001b[32m$currentUserId\u001b[0m');
//       if (currentUserId == null) {
//         developer.log('[_initializeChat] User not logged in');
//         setState(() {
//           _error = 'User not logged in';
//           _isLoading = false;
//         });
//         return;
//       }
//       final chatService = ref.read(chatServiceProvider(currentUserId));
//       developer.log('[_initializeChat] Getting or creating chat room for participantId: '
//           '${widget.conversation.participantId}');
//       _chatId = await chatService.getOrCreateChatRoom(widget.conversation.participantId);
//       developer.log('[_initializeChat] chatId result: $_chatId');
//       if (_chatId == null) {
//         developer.log('[_initializeChat] Failed to create chat room');
//         setState(() {
//           _error = 'Failed to create chat room';
//           _isLoading = false;
//         });
//         return;
//       }
//       _messageSubscription?.cancel();
//       _messageSubscription = chatService.getMessages(_chatId!).listen(
//         (messages) async {
//           developer.log('[_initializeChat] Received messages: ${messages.length}');
//           if (mounted) {
//             developer.log('[_initializeChat] Setting messages and marking as read');
//             final newMessages = messages.map((msg) {
//               developer.log('Message ID: \u001b[36m${msg['id']}\u001b[0m, Created At: ${msg['created_at']}');
//               return ChatMessage(
//                 id: msg['id'],
//                 chatId: _chatId!,
//                 senderId: msg['sender_id'],
//                 content: msg['message'],
//                 timestamp: DateTime.parse(msg['created_at']).toLocal(),
//                 isRead: msg['is_read'],
//               );
//             }).toList();
            
//             // Check if new messages were added
//             final hasNewMessages = newMessages.length > _previousMessageCount;
            
//             setState(() {
//               _messages = newMessages;
//               _isLoading = false;
//             });
            
//             // Only scroll to bottom if new messages were added (not updates)
//             if (hasNewMessages && _previousMessageCount > 0) {
//               _scrollToBottom();
//             }
            
//             // Update the previous count
//             _previousMessageCount = newMessages.length;
//             await chatService.markMessagesAsRead(_chatId!);
//           }
//         },
//         onError: (error) {
//           developer.log('[_initializeChat] Error in message subscription: $error', level: 1000);
//           if (mounted) {
//             setState(() {
//               if (error is OperationException && error.linkException?.originalException is TimeoutException) {
//                 _error = 'Connection timed out. Please check your internet connection and try again.';
//               } else if (error is OperationException && error.linkException != null) {
//                 _error = 'Network error. Please check your connection.';
//               } else {
//                 _error = 'Error loading messages: \u001b[31m${error.toString()}\u001b[0m';
//               }
//               _isLoading = false;
//             });
//           }
//         },
//       );
//       developer.log('[_initializeChat] Message subscription set up');
//     } catch (e, stack) {
//       developer.log('[_initializeChat] Exception: $e', error: e, stackTrace: stack, level: 1000);
//       if (mounted) {
//         setState(() {
//           if (e is OperationException && e.linkException?.originalException is TimeoutException) {
//             _error = 'Connection timed out. Please check your internet connection and try again.';
//           } else if (e is OperationException && e.linkException != null) {
//             _error = 'Network error. Please check your connection.';
//           } else {
//             _error = 'Error initializing chat: \u001b[31m${e.toString()}\u001b[0m';
//           }
//           _isLoading = false;
//         });
//       }
//     }
//     developer.log('[_initializeChat] End');
//   }

//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty || _chatId == null || _isSending) return;

//     try {
//       setState(() => _isSending = true);
      
//       final currentUserId = ref.watch(userIdProvider);
//       if (currentUserId == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User not logged in')),
//         );
//         return;
//       }

//       final chatService = ref.read(chatServiceProvider(currentUserId));
      
//       if (_editingMessage != null) {
//         // Update existing message
//         await chatService.updateMessage(_editingMessage!.id, _messageController.text.trim());
//         setState(() {
//           _editingMessage = null; // Clear editing state
//           _messageController.clear(); // Clear the input field
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Message updated')),
//         );
//       } else {
//         // Send new message
//         await chatService.sendMessage(_chatId!, _messageController.text.trim());
//         _scrollToBottom();
//       }
//     } catch (e) {
//       // Check if the error is an OperationException containing a TimeoutException
//       bool isTimeoutError = false;
//       if (e is OperationException && e.linkException != null) {
//         var innerException = e.linkException;
//         // We might need to check multiple levels of originalException
//         if (innerException is UnknownException) {
//            if (innerException.originalException is TimeoutException) {
//               isTimeoutError = true;
//            }
//         } else if (innerException is NetworkException) { // Also check for NetworkException wrapping timeout
//            if (innerException.originalException is TimeoutException) {
//               isTimeoutError = true;
//            }
//         }
//         // Add checks for other potential exception types wrapping TimeoutException if necessary
//       }

//       if (!isTimeoutError) {
//         // Show a SnackBar for non-timeout errors or errors without linkExceptions
//         String errorMessage = 'Error sending message: ${e.toString()}';
//         if (e is OperationException && e.linkException != null) {
//           errorMessage = 'Network error. Please check your connection.';
//         } else if (e is OperationException && e.graphqlErrors != null && e.graphqlErrors!.isNotEmpty) {
//           // Optionally, display GraphQL errors more user-friendly
//           errorMessage = 'GraphQL Error: ${e.graphqlErrors!.first.message}';
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       }
//       // For timeout errors, we assume the message might still go through via subscription,
//       // so we don't show an immediate error SnackBar.
//     } finally {
//       if (mounted) {
//         setState(() => _isSending = false);
//         // Only clear the input field for new messages, not for edited messages
//         if (_editingMessage == null) {
//           _messageController.clear();
//         }
//       }
//     }
//   }

//   Future<void> _editMessage(ChatMessage message) async {
//     final newContent = await showDialog<String>(
//       context: context,
//       builder: (context) => EditMessageDialog(
//         initialMessage: message.content,
//         onSave: (newContent) async {
//           final currentUserId = ref.watch(userIdProvider);
//           if (currentUserId == null) return;
          
//           final chatService = ref.read(chatServiceProvider(currentUserId));
//           await chatService.updateMessage(message.id, newContent);
//         },
//       ),
//     );

//     if (newContent != null) {
//       try {
//         final currentUserId = ref.watch(userIdProvider);
//         if (currentUserId == null) return;
        
//         final chatService = ref.read(chatServiceProvider(currentUserId));
//         await chatService.updateMessage(message.id, newContent);
//       } catch (e) {
//         developer.log('Error updating message: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error updating message: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _deleteMessage(ChatMessage message) async {
//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Warning Icon
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: const Icon(
//                   Icons.delete_outline,
//                   color: Colors.red,
//                   size: 30,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Title
//               const Text(
//                 'Delete Message',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1E232C),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 12),
//               // Description
//               const Text(
//                 'Are you sure you want to delete this message? This action cannot be undone.',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Color(0xFF8391A1),
//                   height: 1.4,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               // Action Buttons
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextButton(
//                       onPressed: () => Navigator.of(context).pop(false),
//                       style: TextButton.styleFrom(
//                         foregroundColor: const Color(0xFF8391A1),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text(
//                         'Cancel',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.of(context).pop(true),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: const Text(
//                         'Delete',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     if (shouldDelete == true) {
//       try {
//         final currentUserId = ref.watch(userIdProvider);
//         if (currentUserId == null) return;
        
//         final chatService = ref.read(chatServiceProvider(currentUserId));
//         await chatService.deleteMessage(message.id);
//       } catch (e) {
//         developer.log('Error deleting message: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error deleting message: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

//   Widget _buildErrorWidget(String errorMessage) {
//     return RefreshIndicator(
//       onRefresh: _initializeChat,
//       child: ListView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         children: [
//           SizedBox(height: MediaQuery.of(context).size.height * 0.18),
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.error_outline_rounded,
//                     size: 48,
//                     color: Color(0xFF4169E1),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Unable to load chat',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Pull down to refresh the page',
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: Colors.black54,
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool canSendMessage = _messageController.text.trim().isNotEmpty && !_isSending;
    
//     if (_error != null) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.black),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         body: _buildErrorWidget(_error!),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Color.fromARGB(255, 153, 174, 239),
//                   width: 2,
//                 ),
//               ),
//               child: CircleAvatar(
//                 backgroundColor: const Color(0xFF4169E1),
//                 radius: 20,
//                 backgroundImage: widget.conversation.participantAvatar != null && widget.conversation.participantAvatar!.isNotEmpty
//                     ? NetworkImage(widget.conversation.participantAvatar!)
//                     : null,
//                 child: widget.conversation.participantAvatar == null || widget.conversation.participantAvatar!.isEmpty
//                     ? Text(
//                         widget.conversation.participantName[0].toUpperCase(),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       )
//                     : null,
//               ),
//             ),
//             const SizedBox(width: 10),
//             Text(
//               widget.conversation.participantName,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF1E232C),
//                 letterSpacing: -0.5,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF1E232C)),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(
//               child: SizedBox(
//                 width: 40,
//                 height: 40,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               ),
//             )
//           : _messages.isEmpty
//               ? Column(
//                   children: [
//                     const SizedBox(height: 96),
//                     Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF4169E1).withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.chat_bubble_outline,
//                         size: 40,
//                         color: Color(0xFF4169E1),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'No messages yet',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1E232C),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Start the conversation by sending a message',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF8391A1),
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const Spacer(),
//                     _buildMessageInput(canSendMessage),
//                   ],
//                 )
//               : Column(
//                   children: [
//                     Expanded(
//                       child: _buildStickyMessageList(),
//                     ),
//                     _buildMessageInput(canSendMessage),
//                   ],
//                 ),
//     );
//   }

//   Widget _buildStickyMessageList() {
//     // Group messages by date (descending, for reverse ListView)
//     final List<_DateGroup> dateGroups = [];
//     if (_messages.isNotEmpty) {
//       List<ChatMessage> currentGroup = [];
//       DateTime? currentDate;
//       for (int i = _messages.length - 1; i >= 0; i--) {
//         final msg = _messages[i];
//         final msgDate = DateTime(msg.timestamp.year, msg.timestamp.month, msg.timestamp.day);
//         if (currentDate == null || currentDate != msgDate) {
//           if (currentGroup.isNotEmpty) {
//             dateGroups.add(_DateGroup(date: currentDate!, messages: List.from(currentGroup)));
//             currentGroup.clear();
//           }
//           currentDate = msgDate;
//         }
//         currentGroup.add(msg);
//       }
//       if (currentGroup.isNotEmpty && currentDate != null) {
//         dateGroups.add(_DateGroup(date: currentDate!, messages: List.from(currentGroup)));
//       }
//     }
//     // Now dateGroups is in descending order (newest date first), but we want to show newest at bottom (reverse: true)
//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//       reverse: true,
//       physics: const AlwaysScrollableScrollPhysics(),
//       itemCount: dateGroups.length,
//       itemBuilder: (context, groupIndex) {
//         final group = dateGroups[groupIndex];
//         final now = DateTime.now();
//         final today = DateTime(now.year, now.month, now.day);
//         final yesterday = today.subtract(const Duration(days: 1));
//         String dateSeparatorText;
//         if (group.date == today) {
//           dateSeparatorText = 'Today';
//         } else if (group.date == yesterday) {
//           dateSeparatorText = 'Yesterday';
//         } else {
//           dateSeparatorText = DateFormat('MMM d, yyyy').format(group.date);
//         }
//         return StickyHeader(
//           header: Center(
//             child: Container(
//               margin: const EdgeInsets.symmetric(vertical: 8.0),
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 dateSeparatorText,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.black54,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               for (final message in group.messages.reversed)
//                 _buildMessageBubble(message),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMessageInput(bool canSendMessage) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 3,
//             offset: const Offset(0, -1),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Expanded(
//             child: Container(
//               constraints: const BoxConstraints(
//                 maxHeight: 120,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: TextField(
//                         controller: _messageController,
//                         focusNode: _messageFocusNode,
//                         maxLines: null,
//                         minLines: 1,
//                         keyboardType: TextInputType.multiline,
//                         textInputAction: TextInputAction.newline,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Color(0xFF1E232C),
//                           letterSpacing: -0.2,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: _editingMessage != null ? 'Edit message...' : 'Type a message...',
//                           hintStyle: const TextStyle(
//                             color: Color(0xFF8391A1),
//                             fontSize: 16,
//                             letterSpacing: -0.2,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//                           suffixIcon: _editingMessage != null ? IconButton(
//                             icon: const Icon(Icons.close, color: Colors.grey),
//                             onPressed: () {
//                               setState(() {
//                                 _editingMessage = null;
//                                 _messageController.clear();
//                               });
//                             },
//                           ) : null,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(right: 8, bottom: 8),
//                     child: Material(
//                       color: canSendMessage 
//                           ? const Color(0xFF4169E1) 
//                           : Colors.grey,
//                       shape: const CircleBorder(),
//                       child: InkWell(
//                         onTap: _isSending || _messageController.text.trim().isEmpty ? null : _sendMessage,
//                         customBorder: const CircleBorder(),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8),
//                           child: _isSending
//                               ? const SizedBox(
//                                   width: 20,
//                                   height: 20,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                   ),
//                                 )
//                               : Icon(
//                                   _editingMessage != null ? Icons.check : Icons.send_rounded,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(ChatMessage message) {
//     final isMe = message.senderId == ref.watch(userIdProvider);
//     final now = DateTime.now();
//     final isToday = message.timestamp.year == now.year &&
//         message.timestamp.month == now.month &&
//         message.timestamp.day == now.day;
//     final displayText = DateFormat('h:mm a').format(message.timestamp);
    
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: GestureDetector(
//           onTap: isMe ? () {
//             try {
//               HapticFeedback.mediumImpact();
              
//               // Get the render box of the Container (message bubble)
//               final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
//               if (renderBox != null) {
//                 // Get the position of the message bubble
//                 final Offset messagePosition = renderBox.localToGlobal(Offset.zero);
//                 print('Message position: $messagePosition');
                
//                 MessageActionDialog.showAtPosition(
//                   context: context,
//                   targetBox: renderBox,
//                   isOwnMessage: isMe,
//                   onEdit: () {
//                     // Put the message text in the input field for editing
//                     setState(() {
//                       _editingMessage = message;
//                       _messageController.text = message.content;
//                     });
//                     // Focus the input field to open keyboard
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       _messageFocusNode.requestFocus();
//                     });
//                   },
//                   onDelete: () async {
//                     // Unfocus the text field to prevent keyboard from opening
//                     _messageFocusNode.unfocus();
                    
//                     try {
//                       final currentUserId = ref.watch(userIdProvider);
//                       if (currentUserId == null) return;
                      
//                       final chatService = ref.read(chatServiceProvider(currentUserId));
//                       await chatService.deleteMessage(message.id);
                      
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Message deleted')),
//                       );
//                     } catch (e) {
//                       developer.log('Error deleting message: $e');
//                       if (mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text('Error deleting message: $e'),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       }
//                     }
//                   },
//                   messageText: message.content,
//                 );
//               } else {
//                 print('Render box is null!');
//               }
//             } catch (e) {
//               print('Error in long press: $e');
//               // Fallback to simple alert
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('Message Actions'),
//                   content: const Text('Edit, Copy, Delete'),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('OK'),
//                     ),
//                   ],
//                 ),
//               );
//             }
//           } : null,
//           child: Container(
//             constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.85,
//           ),
//           margin: EdgeInsets.only(
//             left: isMe ? 48.0 : 8.0,
//             right: isMe ? 8.0 : 48.0,
//             bottom: 8.0,
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//           decoration: BoxDecoration(
//             color: isMe ? const Color(0xFF4169E1) : const Color(0xFFF5F7FA),
//             borderRadius: BorderRadius.only(
//               topLeft: const Radius.circular(20),
//               topRight: const Radius.circular(20),
//               bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
//               bottomRight: isMe ? Radius.zero : const Radius.circular(20),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//             children: [
//               Text(
//                 message.content,
//                 style: TextStyle(
//                   color: isMe ? Colors.white : const Color(0xFF1E232C),
//                   fontSize: 16.0,
//                 ),
//               ),
//               if (message.hasBeenEdited) ...[
//                 const SizedBox(height: 4),
//                 Text(
//                   'Edited',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: isMe ? Colors.white70 : Colors.grey,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               ],
//               if (_editingMessage?.id == message.id) ...[
//                 const SizedBox(height: 4),
//                 Text(
//                   'Editing...',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: isMe ? Colors.white70 : Colors.grey,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Note: Since updated_at field doesn't exist in the schema,
//                   // we can't track edited messages. The isEdited property
//                   // is set to false by default.
//                   // To implement edited tracking, you would need to add
//                   // an updated_at column to your messages table in the database.
//                   Text(
//                     displayText,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: isMe ? Colors.white70 : const Color(0xFF8391A1),
//                       letterSpacing: -0.2,
//                     ),
//                   ),
//                   if (isMe) ...[
//                     const SizedBox(width: 4),
//                     Icon(
//                       message.isRead ? Icons.done_all : Icons.done,
//                       size: 16,
//                       color: message.isRead ? Colors.white70 : Colors.white70,
//                     ),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Helper class for grouping messages by date
// class _DateGroup {
//   final DateTime date;
//   final List<ChatMessage> messages;
//   _DateGroup({required this.date, required this.messages});
// } 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sticky_headers/sticky_headers.dart';

// Import your existing files
import '../../models/chat_message.dart';
import '../../models/conversation.dart';
import '../../services/chat_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/custom_message_overlay.dart';
// import '../../widgets/edit_message_dialog.dart';
import '../../utils/avatar_utils.dart';
// import '../widgets/custom_message_overlay.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final Conversation conversation;

  const ChatDetailScreen({
    Key? key,
    required this.conversation,
  }) : super(key: key);

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  
  // Create a map to store GlobalKeys for each message
  final Map<String, GlobalKey> _messageKeys = {};
  
  String? _chatId;
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _messageSubscription;
  bool _isSending = false;
  ChatMessage? _editingMessage;
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onMessageTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeChat();
  }

  void _onMessageTextChanged() {
    setState(() {}); // Rebuild to update send button state
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _messageSubscription?.cancel();
    CustomMessageOverlay.hide(); // Clean up overlay
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _initializeChat() async {
    developer.log('[_initializeChat] Called');
    try {
      if (mounted) {
        setState(() {
          _error = null;
        });
      }
      final currentUserId = ref.watch(currentUserIdProvider);
      developer.log('[_initializeChat] currentUserId: '
          '\u001b[32m$currentUserId\u001b[0m');

      if (currentUserId == null) {
        developer.log('[_initializeChat] User not logged in');
        setState(() {
          _error = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      final chatService = ref.read(chatServiceProvider(currentUserId));
      developer.log('[_initializeChat] Getting or creating chat room for participantId: '
          '${widget.conversation.participantId}');

      _chatId = await chatService.getOrCreateChatRoom(widget.conversation.participantId);
      developer.log('[_initializeChat] chatId result: $_chatId');

      if (_chatId == null) {
        developer.log('[_initializeChat] Failed to create chat room');
        setState(() {
          _error = 'Failed to create chat room';
          _isLoading = false;
        });
        return;
      }

      _messageSubscription?.cancel();
      _messageSubscription = chatService.getMessages(_chatId!).listen(
        (messages) async {
          developer.log('[_initializeChat] Received messages: ${messages.length}');
          if (mounted) {
            developer.log('[_initializeChat] Setting messages and marking as read');
            final newMessages = messages.map((msg) {
              developer.log('Message ID: \u001b[36m${msg['id']}\u001b[0m, Created At: ${msg['created_at']}');
              return ChatMessage(
                id: msg['id'],
                chatId: _chatId!,
                senderId: msg['sender_id'],
                content: msg['message'],
                timestamp: DateTime.parse(msg['created_at']).toLocal(),
                isRead: msg['is_read'],
              );
            }).toList();
                        
            // Check if new messages were added
            final hasNewMessages = newMessages.length > _previousMessageCount;
                        
            setState(() {
              _messages = newMessages;
              _isLoading = false;
            });
                        
            // Only scroll to bottom if new messages were added (not updates)
            if (hasNewMessages && _previousMessageCount > 0) {
              _scrollToBottom();
            }
                        
            // Update the previous count
            _previousMessageCount = newMessages.length;
            await chatService.markMessagesAsRead(_chatId!);
          }
        },
        onError: (error) {
          developer.log('[_initializeChat] Error in message subscription: $error', level: 1000);
          if (mounted) {
            setState(() {
              if (error is OperationException && error.linkException?.originalException is TimeoutException) {
                _error = 'Connection timed out. Please check your internet connection and try again.';
              } else if (error is OperationException && error.linkException != null) {
                _error = 'Network error. Please check your connection.';
              } else {
                _error = 'Error loading messages: \u001b[31m${error.toString()}\u001b[0m';
              }
              _isLoading = false;
            });
          }
        },
      );
      developer.log('[_initializeChat] Message subscription set up');
    } catch (e, stack) {
      developer.log('[_initializeChat] Exception: $e', error: e, stackTrace: stack, level: 1000);
      if (mounted) {
        setState(() {
          if (e is OperationException && e.linkException?.originalException is TimeoutException) {
            _error = 'Connection timed out. Please check your internet connection and try again.';
          } else if (e is OperationException && e.linkException != null) {
            _error = 'Network error. Please check your connection.';
          } else {
            _error = 'Error initializing chat: \u001b[31m${e.toString()}\u001b[0m';
          }
          _isLoading = false;
        });
      }
    }
    developer.log('[_initializeChat] End');
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatId == null || _isSending) return;

    try {
      setState(() => _isSending = true);
            
      final currentUserId = ref.watch(userIdProvider);
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final chatService = ref.read(chatServiceProvider(currentUserId));
            
      if (_editingMessage != null) {
        // Update existing message
        await chatService.updateMessage(_editingMessage!.id, _messageController.text.trim());
        setState(() {
          _editingMessage = null; // Clear editing state
          _messageController.clear(); // Clear the input field
        });
        // Removed SnackBar for 'Message updated'
      } else {
        // Send new message
        await chatService.sendMessage(_chatId!, _messageController.text.trim());
        _scrollToBottom();
      }
    } catch (e) {
      // Check if the error is an OperationException containing a TimeoutException
      bool isTimeoutError = false;
      if (e is OperationException && e.linkException != null) {
        var innerException = e.linkException;
        // We might need to check multiple levels of originalException
        if (innerException is UnknownException) {
           if (innerException.originalException is TimeoutException) {
              isTimeoutError = true;
           }
        } else if (innerException is NetworkException) { // Also check for NetworkException wrapping timeout
           if (innerException.originalException is TimeoutException) {
              isTimeoutError = true;
           }
        }
        // Add checks for other potential exception types wrapping TimeoutException if necessary
      }

      if (!isTimeoutError) {
        // Show a SnackBar for non-timeout errors or errors without linkExceptions
        String errorMessage = 'Error sending message: ${e.toString()}';
        if (e is OperationException && e.linkException != null) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e is OperationException && e.graphqlErrors.isNotEmpty) {
          // Optionally, display GraphQL errors more user-friendly
          errorMessage = 'GraphQL Error: ${e.graphqlErrors.first.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      // For timeout errors, we assume the message might still go through via subscription,
      // so we don't show an immediate error SnackBar.
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        // Only clear the input field for new messages, not for edited messages
        if (_editingMessage == null) {
          _messageController.clear();
        }
      }
    }
  }

  // Removed unused _editMessage
  /*Future<void> _editMessage(ChatMessage message) async {
    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => EditMessageDialog(
        initialMessage: message.content,
        onSave: (newContent) async {
          final currentUserId = ref.watch(userIdProvider);
          if (currentUserId == null) return;
                    
          final chatService = ref.read(chatServiceProvider(currentUserId));
          await chatService.updateMessage(message.id, newContent);
        },
      ),
    );

    if (newContent != null) {
      try {
        final currentUserId = ref.watch(userIdProvider);
        if (currentUserId == null) return;
                
        final chatService = ref.read(chatServiceProvider(currentUserId));
        await chatService.updateMessage(message.id, newContent);
      } catch (e) {
        developer.log('Error updating message: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating message: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }*/

  // Removed unused _deleteMessage
  /*Future<void> _deleteMessage(ChatMessage message) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Delete Message',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E232C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Description
              const Text(
                'Are you sure you want to delete this message? This action cannot be undone.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8391A1),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF8391A1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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

    if (shouldDelete == true) {
      try {
        final currentUserId = ref.watch(userIdProvider);
        if (currentUserId == null) return;
                
        final chatService = ref.read(chatServiceProvider(currentUserId));
        await chatService.deleteMessage(message.id);
      } catch (e) {
        developer.log('Error deleting message: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting message: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }*/

  Widget _buildErrorWidget(String errorMessage) {
    return RefreshIndicator(
      onRefresh: _initializeChat,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),
          AppErrorWidget(
            message: 'Unable to load chat',
            onRetry: _initializeChat,
          ),
        ],
      ),
    );
  }

  Widget _buildStickyMessageList() {
    // Group messages by date (descending, for reverse ListView)
    final List<_DateGroup> dateGroups = [];
    if (_messages.isNotEmpty) {
      List<ChatMessage> currentGroup = [];
      DateTime? currentDate;
      for (int i = _messages.length - 1; i >= 0; i--) {
        final msg = _messages[i];
        final msgDate = DateTime(msg.timestamp.year, msg.timestamp.month, msg.timestamp.day);
        if (currentDate == null || currentDate != msgDate) {
          if (currentGroup.isNotEmpty) {
            dateGroups.add(_DateGroup(date: currentDate!, messages: List.from(currentGroup)));
            currentGroup.clear();
          }
          currentDate = msgDate;
        }
        currentGroup.add(msg);
      }
      if (currentGroup.isNotEmpty && currentDate != null) {
        dateGroups.add(_DateGroup(date: currentDate, messages: List.from(currentGroup)));
      }
    }

    // Now dateGroups is in descending order (newest date first), but we want to show newest at bottom (reverse: true)
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      reverse: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: dateGroups.length,
      itemBuilder: (context, groupIndex) {
        final group = dateGroups[groupIndex];
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        String dateSeparatorText;
        if (group.date == today) {
          dateSeparatorText = 'Today';
        } else if (group.date == yesterday) {
          dateSeparatorText = 'Yesterday';
        } else {
          dateSeparatorText = DateFormat('MMM d, yyyy').format(group.date);
        }

        return StickyHeader(
          header: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dateSeparatorText,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final message in group.messages.reversed)
                _buildMessageBubble(message),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(bool canSendMessage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 120,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _messageFocusNode,
                        maxLines: null,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1E232C),
                          letterSpacing: -0.2,
                        ),
                        decoration: InputDecoration(
                          hintText: _editingMessage != null ? 'Edit message...' : 'Type a message...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF8391A1),
                            fontSize: 16,
                            letterSpacing: -0.2,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          suffixIcon: _editingMessage != null ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _editingMessage = null;
                                _messageController.clear();
                              });
                            },
                          ) : null,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, bottom: 8),
                    child: Material(
                      color: canSendMessage
                           ? const Color(0xFF4169E1)
                           : Colors.grey,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _isSending || _messageController.text.trim().isEmpty ? null : _sendMessage,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(
                                  _editingMessage != null ? Icons.check : Icons.send_rounded,
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

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == ref.watch(userIdProvider);
    final displayText = DateFormat('h:mm a').format(message.timestamp);
    
    // Create or get the GlobalKey for this message
    _messageKeys[message.id] ??= GlobalKey();
    final messageKey = _messageKeys[message.id]!;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: isMe ? () {
          CustomMessageOverlay.showAtMessage(
            context: context,
            messageKey: messageKey,
            isOwnMessage: isMe,
            onEdit: () {
              setState(() {
                _editingMessage = message;
                _messageController.text = message.content;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _messageFocusNode.requestFocus();
              });
            },
            onDelete: () async {
              _messageFocusNode.unfocus();
              try {
                final currentUserId = ref.watch(userIdProvider);
                if (currentUserId == null) return;

                final chatService = ref.read(chatServiceProvider(currentUserId));
                await chatService.deleteMessage(message.id);
              } catch (e) {
                developer.log('Error deleting message: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting message: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            messageText: message.content,
          );
        } : null,
        child: Container(
          key: messageKey, // Important: Add the key here
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          margin: EdgeInsets.only(
            left: isMe ? 48.0 : 8.0,
            right: isMe ? 8.0 : 48.0,
            bottom: 8.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF4169E1) : const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : const Color(0xFF1E232C),
                  fontSize: 16.0,
                ),
              ),
              if (message.hasBeenEdited) ...[
                const SizedBox(height: 4),
                Text(
                  'Edited',
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white70 : Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (_editingMessage?.id == message.id) ...[
                const SizedBox(height: 4),
                Text(
                  'Editing...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white70 : Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isMe ? Colors.white70 : const Color(0xFF8391A1),
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 16,
                      color: message.isRead ? Colors.white70 : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canSendMessage = _messageController.text.trim().isNotEmpty && !_isSending;
        
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _buildErrorWidget(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color.fromARGB(255, 153, 174, 239),
                  width: 2,
                ),
              ),
              child: Builder(
                builder: (context) {
                  final ImageProvider? avatarImage = AvatarUtils.getProfileImage(widget.conversation.participantAvatar);
                  return CircleAvatar(
                    radius: 20,
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
            ),
            const SizedBox(width: 10),
            Text(
              widget.conversation.participantName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E232C),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E232C)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : _messages.isEmpty
              ? Column(
                  children: [
                    const SizedBox(height: 96),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4169E1).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        size: 40,
                        color: Color(0xFF4169E1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No messages yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E232C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start the conversation by sending a message',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8391A1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    _buildMessageInput(canSendMessage),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: _buildStickyMessageList(),
                    ),
                    _buildMessageInput(canSendMessage),
                  ],
                ),
    );
  }
}

// Helper class for grouping messages by date
class _DateGroup {
  final DateTime date;
  final List<ChatMessage> messages;
  _DateGroup({required this.date, required this.messages});
}
