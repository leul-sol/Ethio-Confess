const String userUpdateMutation = '''
mutation MyMutation {
  update_users_by_pk(pk_columns: {id: "6668b829-928a-4704-bd94-6a6402b33438"}, _set: {onesignal_player_id: "12345"}) {
    id
    onesignal_player_id
    username
  }
}
''';