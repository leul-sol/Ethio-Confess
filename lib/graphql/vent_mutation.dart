const String createVentMutation = r'''
mutation CreateVent($objects: [vent_insert_input!]!) {
  insert_vent(objects: $objects) {
    affected_rows
    returning {
      id
      content
      created_at
    }
  }
}
''';

const insertVentReplyMutation = """
mutation InsertVentReply(\$objects: [ventreplies_insert_input!]!) {
  insert_ventreplies(objects: \$objects) {
    affected_rows
    returning {
      id
      reply
      created_at
      user {
        username
      }
    }
  }
}
""";

const String updateVentReplyMutation = '''
  mutation UpdateVentReply(\$id: uuid!, \$reply: String!) {
    update_ventreplies(
      where: {id: {_eq: \$id}},
      _set: {reply: \$reply}
    ) {
      affected_rows
      returning {
        id
        reply
        created_at
        updated_at
        user_id
        vent_id
        user {
          id
          username
          email
        }
        vent {
          id
        }
      }
    }
  }
''';
