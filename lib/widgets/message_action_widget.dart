import 'package:flutter/material.dart';

class MessageActionWidget extends StatefulWidget {
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onPin;
  final VoidCallback? onCopyText;
  final VoidCallback? onForward;
  final VoidCallback? onDelete;
  final VoidCallback? onSelect;
  final bool isOwnMessage;
  final bool showReply;
  final bool showPin;
  final bool showCopyText;
  final bool showForward;
  final bool showSelect;

  const MessageActionWidget({
    Key? key,
    this.onReply,
    this.onEdit,
    this.onPin,
    this.onCopyText,
    this.onForward,
    this.onDelete,
    this.onSelect,
    required this.isOwnMessage,
    this.showReply = true,
    this.showPin = true,
    this.showCopyText = true,
    this.showForward = true,
    this.showSelect = true,
  }) : super(key: key);

  @override
  State<MessageActionWidget> createState() => _MessageActionWidgetState();
}

class _MessageActionWidgetState extends State<MessageActionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildActionItem({
    required IconData icon,
    required String text,
    required VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? (isDestructive ? Colors.red : Colors.grey[700]),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: textColor ?? (isDestructive ? Colors.red : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[800], // Dark theme like in the image
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply Option
            if (widget.showReply && widget.onReply != null)
              _buildActionItem(
                icon: Icons.reply,
                text: 'Reply',
                onTap: widget.onReply,
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
            
            // Edit Option (only for own messages)
            if (widget.isOwnMessage && widget.onEdit != null)
              _buildActionItem(
                icon: Icons.edit,
                text: 'Edit',
                onTap: widget.onEdit,
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
            
            // Pin Option
            if (widget.showPin && widget.onPin != null)
              _buildActionItem(
                icon: Icons.push_pin,
                text: 'Pin',
                onTap: widget.onPin,
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
            
            // Copy Text Option
            if (widget.showCopyText && widget.onCopyText != null)
              _buildActionItem(
                icon: Icons.copy,
                text: 'Copy Text',
                onTap: widget.onCopyText,
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
            
            // Forward Option
            if (widget.showForward && widget.onForward != null)
              _buildActionItem(
                icon: Icons.forward,
                text: 'Forward',
                onTap: widget.onForward,
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
            
            // Delete Option (only for own messages)
            if (widget.isOwnMessage && widget.onDelete != null)
              _buildActionItem(
                icon: Icons.delete,
                text: 'Delete',
                onTap: widget.onDelete,
                isDestructive: true,
                iconColor: Colors.red,
                textColor: Colors.red,
              ),
            
            // Select Option
            if (widget.showSelect && widget.onSelect != null)
              _buildActionItem(
                icon: Icons.check_circle_outline,
                text: 'Select',
                onTap: widget.onSelect,
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
} 