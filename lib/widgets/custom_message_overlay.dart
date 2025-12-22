import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomMessageOverlay {
  static OverlayEntry? _overlayEntry;

  static void showAtMessage({
    required BuildContext context,
    required GlobalKey messageKey,
    required bool isOwnMessage,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required String messageText,
  }) {
    // Remove any existing overlay
    _overlayEntry?.remove();

    // Get the render box of the message
    final RenderBox? renderBox = messageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Get the position and size of the message
    final Offset messagePosition = renderBox.localToGlobal(Offset.zero);
    final Size messageSize = renderBox.size;

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Create overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => _MessageActionOverlay(
        messagePosition: messagePosition,
        messageSize: messageSize,
        isOwnMessage: isOwnMessage,
        onEdit: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
          onEdit();
        },
        onDelete: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
          onDelete();
        },
        onCopy: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
          Clipboard.setData(ClipboardData(text: messageText));
        },
        onDismiss: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    // Insert overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _MessageActionOverlay extends StatelessWidget {
  final Offset messagePosition;
  final Size messageSize;
  final bool isOwnMessage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onDismiss;

  const _MessageActionOverlay({
    required this.messagePosition,
    required this.messageSize,
    required this.isOwnMessage,
    required this.onEdit,
    required this.onDelete,
    required this.onCopy,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate position for the action menu
    double left = messagePosition.dx;
    double top = messagePosition.dy - 60; // Show above the message
    
    // Adjust if it would go off screen
    if (top < 100) {
      top = messagePosition.dy + messageSize.height + 10; // Show below instead
    }
    
    if (left + 200 > screenSize.width) {
      left = screenSize.width - 220; // Adjust to fit on screen
    }

    return Stack(
      children: [
        // Transparent background to catch taps
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        // Action menu
        Positioned(
          left: left,
          top: top,
          child: Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 232, 240, 252),
                borderRadius: BorderRadius.circular(12),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.1),
                //     blurRadius: 10,
                //     offset: const Offset(0, 4),
                //   ),
                // ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: Icons.copy,
                    label: 'Copy',
                    color: Colors.grey[600]!,
                    onTap: onCopy,
                  ),
                  if (isOwnMessage) ...[
                    _ActionButton(
                      icon: Icons.edit,
                      label: 'Edit',
                      color: Colors.blue[600]!,
                      onTap: onEdit,
                    ),
                    _ActionButton(
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.red[600]!,
                      onTap: onDelete,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
