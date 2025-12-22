import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageActionDialog {
  static Future<void> showAtPosition({
    required BuildContext context,
    required RenderBox targetBox,
    required bool isOwnMessage,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    String? messageText,
  }) {
    print('showAtPosition called!'); // Debug print
    print('Target box size: ${targetBox.size}'); // Debug print
    
    try {
      final RenderBox? overlay = Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
      if (overlay == null) {
        print('Overlay is null!');
        return Future.value();
      }
      
      // Position the dialog in the center of the screen, but use the message's horizontal position
      final Offset messageTopLeft = targetBox.localToGlobal(Offset.zero, ancestor: overlay);
      final double screenWidth = overlay.size.width;
      final double dialogWidth = 200.0;
      
      // Center the dialog horizontally, but use the message's left position as a guide
      final double left = (messageTopLeft.dx + targetBox.size.width / 2) - (dialogWidth / 2);
      
      final RelativeRect position = RelativeRect.fromLTRB(
        left,
        MediaQuery.of(context).size.height * 0.3, // Position in upper third
        screenWidth - left - dialogWidth,
        0,
      );

      print('About to show menu at position: $position'); // Debug print
                 return showMenu(
             context: context,
             position: position,
             color: Colors.white,
             elevation: 1, // Small, even shadow
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(12),
             ),
        items: [
          if (isOwnMessage && onEdit != null)
            PopupMenuItem(
              height: 40,
              child: _buildMenuItem(
                icon: Icons.edit,
                text: 'Edit',
                onTap: () {
                  Navigator.pop(context); // Dismiss menu
                  onEdit();
                },
              ),
            ),
          PopupMenuItem(
            height: 40,
            child: _buildMenuItem(
              icon: Icons.copy,
              text: 'Copy Text',
              onTap: () {
                Navigator.pop(context); // Dismiss menu
                if (messageText != null) {
                  Clipboard.setData(ClipboardData(text: messageText));
                }
              },
            ),
          ),
          if (isOwnMessage && onDelete != null)
            PopupMenuItem(
              height: 40,
              child: _buildMenuItem(
                icon: Icons.delete,
                text: 'Delete',
                onTap: () {
                  Navigator.pop(context); // Dismiss menu
                  onDelete();
                },
                isDestructive: true,
              ),
            ),
        ],
      );
    } catch (e) {
      print('Error in showAtPosition: $e');
      // Fallback to simple alert
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Message Actions'),
          content: const Text('Reply, Copy, Delete'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    return Future.value();
  }

  static Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : const Color(0xFF4169E1),
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : const Color(0xFF1E232C),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 