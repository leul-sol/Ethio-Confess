import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'conversation_providers.dart';

final globalUnreadProvider = StreamProvider<bool>((ref) async* {
  await for (final conversations in ref.watch(conversationStreamProvider.stream)) {
    yield conversations.any((c) => c.unreadCount > 0);
  }
}); 