import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../providers/replay_provider.dart';
// import '../../providers/reply_provider.dart';
import '../../providers/vent_provider.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/vent_widget/vent_detail.dart';
import '../../widgets/vent_widget/vent_replay_input.dart';
import '../../utils/auth_utils.dart';

class VentDetailScreen extends ConsumerStatefulWidget {
  final String ventId;

  const VentDetailScreen({Key? key, required this.ventId}) : super(key: key);

  @override
  ConsumerState<VentDetailScreen> createState() => _VentDetailScreenState();
}

class _VentDetailScreenState extends ConsumerState<VentDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? _editingReply;
  Map<String, dynamic>? _replyingTo;

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleReply() async {
    if (await handleProtectedAction(
      context,
      action: ProtectedAction.comment,
      message: 'Please sign in to reply to vents',
    )) {
      // Only proceed if user is authenticated
      ref.invalidate(ventDetailProvider(widget.ventId));
      // Refresh the main vent list so reply count is up to date
      await ref.read(ventProvider(null).notifier).refresh();
      setState(() {
        _editingReply = null;
        _replyingTo = null;
      });
    }
  }

  void _handleEditReply(Map<String, dynamic> reply) {
    setState(() {
      _editingReply = reply;
      _replyingTo = null;
    });
  }

  void _handleReplyToReply(Map<String, dynamic> reply) {
    setState(() {
      _replyingTo = reply;
      _editingReply = null;
      _replyController.clear();
    });
  }

  void _handleCancelEdit() {
    setState(() {
      _editingReply = null;
      _replyingTo = null;
      _replyController.clear();
    });
  }

  void _startChat(BuildContext context, Map<String, dynamic> vent) {
    try {
      if (vent['user'] == null || 
          vent['user']['id'] == null || 
          vent['user']['username'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot start chat: Invalid user data')),
        );
        return;
      }

      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'participantId': vent['user']['id'],
          'participantName': vent['user']['username'],
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting chat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ventDetails = ref.watch(ventDetailProvider(widget.ventId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      // Enable automatic resizing when keyboard appears
      resizeToAvoidBottomInset: true,
      body: ventDetails.when(
        data: (vent) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  // Enable scrolling for the content area
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: VentDetail(
                    vent: vent,
                    onEditReply: _handleEditReply,
                    onReplyToReply: _handleReplyToReply,
                    onStartChat: (vent) => _startChat(context, vent),
                  ),
                ),
              ),
              // Use SafeArea to ensure input is always visible
              SafeArea(
                child: ReplyInput(
                  controller: _replyController,
                  ventId: widget.ventId,
                  onReplySubmitted: _handleReply,
                  editingReply: _editingReply,
                  onEditCancel: _handleCancelEdit,
                  parentId: _replyingTo?['id'],
                  replyingToUser: _replyingTo != null ? _replyingTo!['user'] : null,
                  scrollController: _scrollController,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Color(0xFF4169E1),
              strokeWidth: 2,
            ),
          ),
        ),
        error: (error, stackTrace) {
          Future<void> onRefresh() async {
            ref.invalidate(ventDetailProvider(widget.ventId));
          }
          return Center(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                  AppErrorWidget(
                    message: 'Unable to load vent',
                    onRetry: onRefresh,
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
