const String getChatsQuery = '''
  query GetChats(\$userId: uuid!) {
    chats(
      where: {
        _or: [
          {user1: {_eq: \$userId}},
          {user2: {_eq: \$userId}}
        ]
      },
      distinct_on: [user1, user2],
      order_by: [
        {user1: asc},
        {user2: asc},
        {created_at: desc}
      ]
    ) {
      id
      user1
      user2
      created_at
      user {
        id
        username
        email
        profile_image
      }
      userByUser2 {
        id
        username
        email
        profile_image
      }
      messages(order_by: {created_at: desc}) {
        id
        message
        sender_id
        created_at
        is_read
      }
    }
  }
''';

const String getMessagesQuery = '''
  query GetMessages(\$chatId: uuid!) {
    chats_by_pk(id: \$chatId) {
      id
      user1
      user2
      user {
        username
      }
      userByUser2 {
        username
      }
      messages(order_by: {created_at: asc}) {
        id
        chat_id
        message
        sender_id
        created_at
        is_read
      }
    }
  }
''';

const String getMessagesSubscription = '''
  subscription GetMessages(\$chatId: uuid!) {
    messages(
      where: {chat_id: {_eq: \$chatId}},
      order_by: {created_at: asc}
    ) {
      id
      chat_id
      message
      sender_id
      created_at
      is_read
    }
  }
''';

const String sendMessageMutation = '''
  mutation SendMessage(\$chatId: uuid!, \$message: String!, \$senderId: uuid!) {
    insert_messages_one(object: {
      chat_id: \$chatId,
      message: \$message,
      sender_id: \$senderId,
      is_read: false
    }) {
      id
      chat_id
      message
      sender_id
      created_at
      is_read
    }
  }
''';

const String createChatMutation = '''
  mutation CreateChat(\$user1: uuid!, \$user2: uuid!) {
    insert_chats_one(object: {
      user1: \$user1,
      user2: \$user2
    }) {
      id
      user1
      user2
      created_at
    }
  }
''';

const String markMessagesAsReadMutation = '''
  mutation MarkMessagesAsRead(\$chatId: uuid!, \$userId: uuid!) {
    update_messages(
      where: {
        chat_id: {_eq: \$chatId},
        sender_id: {_neq: \$userId},
        is_read: {_eq: false}
      },
      _set: {is_read: true}
    ) {
      affected_rows
    }
  }
''';

const String updateMessageMutation = '''
  mutation UpdateMessage(\$messageId: uuid!, \$newContent: String!) {
    update_messages_by_pk(
      pk_columns: {id: \$messageId},
      _set: {message: \$newContent}
    ) {
      id
      message
      created_at
      sender_id
      chat_id
      is_read
    }
  }
''';

const String deleteMessageMutation = '''
  mutation DeleteMessage(\$messageId: uuid!) {
    delete_messages_by_pk(id: \$messageId) {
      id
      chat_id
    }
  }
''';

const String getChatsSubscription = '''
  subscription GetChats(\$userId: uuid!) {
    chats(
      where: {
        _or: [
          {user1: {_eq: \$userId}},
          {user2: {_eq: \$userId}}
        ]
      },
      distinct_on: [user1, user2]
      order_by: [{ user1: asc }, { user2: asc }, { created_at: desc }]
    ) {
      id
      user1
      user2
      created_at
      user {
        id
        username
        email
        profile_image
      }
      userByUser2 {
        id
        username
        email
        profile_image
      }
      messages(order_by: {created_at: desc}) {
        id
        message
        sender_id
        created_at
        is_read
      }
    }
  }
'''; 