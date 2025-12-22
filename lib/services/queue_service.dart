import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class QueueService {
  static const String likeQueueBoxName = 'like_queue';
  static const String replyQueueBoxName = 'reply_queue';
  static const String messageQueueBoxName = 'message_queue';
  
  late Box<Map<dynamic, dynamic>> likeQueueBox;
  late Box<Map<dynamic, dynamic>> replyQueueBox;
  late Box<Map<dynamic, dynamic>> messageQueueBox;

  Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    
    likeQueueBox = await Hive.openBox<Map<dynamic, dynamic>>(likeQueueBoxName);
    replyQueueBox = await Hive.openBox<Map<dynamic, dynamic>>(replyQueueBoxName);
    messageQueueBox = await Hive.openBox<Map<dynamic, dynamic>>(messageQueueBoxName);
  }

  // Like Queue Methods
  Future<void> addLikeToQueue(String biographyId, String userId) async {
    await likeQueueBox.add({
      'biography_id': biographyId,
      'user_id': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<dynamic, dynamic>>> getLikeQueue() async {
    return likeQueueBox.values.toList();
  }

  Future<void> removeLikeFromQueue(int index) async {
    await likeQueueBox.deleteAt(index);
  }

  // Reply Queue Methods
  Future<void> addReplyToQueue(String ventId, String userId, String reply, {String? parentId}) async {
    await replyQueueBox.add({
      'vent_id': ventId,
      'user_id': userId,
      'reply': reply,
      if (parentId != null) 'parent_id': parentId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<dynamic, dynamic>>> getReplyQueue() async {
    return replyQueueBox.values.toList();
  }

  Future<void> removeReplyFromQueue(int index) async {
    await replyQueueBox.deleteAt(index);
  }

  // Message Queue Methods
  Future<void> addMessageToQueue(String chatId, String message, String senderId) async {
    await messageQueueBox.add({
      'chat_id': chatId,
      'message': message,
      'sender_id': senderId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addMessageUpdateToQueue(String messageId, String newContent, String senderId) async {
    await messageQueueBox.add({
      'action': 'update',
      'message_id': messageId,
      'new_content': newContent,
      'sender_id': senderId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addMessageDeletionToQueue(String messageId, String senderId) async {
    await messageQueueBox.add({
      'action': 'delete',
      'message_id': messageId,
      'sender_id': senderId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<dynamic, dynamic>>> getMessageQueue() async {
    return messageQueueBox.values.toList();
  }

  Future<void> removeMessageFromQueue(int index) async {
    await messageQueueBox.deleteAt(index);
  }
} 