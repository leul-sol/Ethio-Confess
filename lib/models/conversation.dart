import 'package:flutter/material.dart';
import 'chat_message.dart';

class Conversation {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isRead;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isRead = true,
    this.unreadCount = 0,
  });
} 