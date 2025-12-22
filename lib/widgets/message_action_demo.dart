import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'message_action_dialog.dart';

class MessageActionDemo extends StatelessWidget {
  const MessageActionDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Action Dialog Demo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tap on a message to see the action dialog:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Demo message 1 - Own message
            _buildDemoMessage(
              context,
              'This is your own message. Long press to see all actions.',
              true,
              'Hello! This is a sample message that you can interact with.',
            ),
            
            const SizedBox(height: 16),
            
            // Demo message 2 - Other person's message
            _buildDemoMessage(
              context,
              'This is someone else\'s message. Long press to see limited actions.',
              false,
              'Hi there! This is a message from another user.',
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Available Actions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildActionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoMessage(BuildContext context, String title, bool isOwnMessage, String messageText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOwnMessage ? const Color(0xFF4169E1) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isOwnMessage ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onLongPress: () {
              final RenderBox renderBox = context.findRenderObject() as RenderBox;
              MessageActionDialog.showAtPosition(
                context: context,
                targetBox: renderBox,
                isOwnMessage: isOwnMessage,
                onEdit: isOwnMessage ? () {
                  // Edit action handled by parent
                } : null,
                onDelete: isOwnMessage ? () {
                  // Delete action handled by parent
                } : null,
                messageText: messageText,
              );
            },
            child: Text(
              messageText,
              style: TextStyle(
                fontSize: 16,
                color: isOwnMessage ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Long press to show actions',
            style: TextStyle(
              fontSize: 12,
              color: isOwnMessage ? Colors.white70 : Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActionItem('Edit', 'Edit your own message', Icons.edit),
        _buildActionItem('Copy Text', 'Copy message to clipboard', Icons.copy),
        _buildActionItem('Delete', 'Delete your own message', Icons.delete, isDestructive: true),
      ],
    );
  }

  Widget _buildActionItem(String title, String description, IconData icon, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive ? Colors.red : Colors.grey[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.red : Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 