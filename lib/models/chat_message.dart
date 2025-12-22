import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final bool isEdited;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.isEdited = false,
  });

  // Check if message has been edited (for now, we'll use isEdited flag)
  bool get hasBeenEdited => isEdited;
}

enum MessageType {
  text,
  image,
  file,
} 