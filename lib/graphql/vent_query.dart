const String ventListQuery = r'''
query ventlist {
  vent(order_by: {created_at: desc}) {
    content
    id
    created_at
    updated_at
    user {
      id
      username
      profile_image
    }
    user_id
    ventreplies(order_by: {created_at: desc}) {
      reply
    }
  }
}
''';
const String ventDetailQuery = """
  query ventDetail(
    \$id: uuid!
  ) {
    vent_by_pk(id: \$id) {
      content
      created_at
      updated_at
      id
      user {
        id
        username
        email
        allow_chat
        profile_image
      }
      ventreplies(order_by: {created_at: desc}) {
        id
        reply
        created_at
        parent_id
        user {
          id
          username
          email
          allow_chat
          profile_image
        }
        children: ventreplies(order_by: {created_at: desc}) {
          id
          reply
          created_at
          parent_id
           user {
             id
             username
             email
             allow_chat
             profile_image
           }
          children: ventreplies(order_by: {created_at: desc}) {
            id
            reply
            created_at
            parent_id
             user {
               id
               username
               email
               allow_chat
               profile_image
             }
            children: ventreplies(order_by: {created_at: desc}) {
              id
              reply
              created_at
              parent_id
               user {
                 id
                 username
                 email
                 allow_chat
                 profile_image
               }
              children: ventreplies(order_by: {created_at: desc}) {
                id
                reply
                created_at
                parent_id
                 user {
                   id
                   username
                   email
                   allow_chat
                   profile_image
                 }
              }
            }
          }
        }
      }
    }
  }
""";

const String getVentsQuery = '''
  query GetVentsByCategory(\$categoryId: uuid!) {
    vent(
      order_by: [{ created_at: desc }]
      where: { vent_category: { id: { _eq: \$categoryId } } }
    ) {
      content
      created_at
      id
      updated_at
      user_id
      user {
        id
        username
        profile_image
      }
      vent_category {
        category_name
        id
      }
      ventreplies(order_by: {created_at: desc}) {
        reply
      }
      ventreplies_aggregate {
        aggregate {
          count
        }
      }
    }
  }
''';

const String getAllVentsQuery = '''
  query GetAllVents {
    vent(
      order_by: [{ created_at: desc }]
    ) {
      content
      created_at
      id
      updated_at
      user_id
      user {
        id
        username
        profile_image
      }
      vent_category {
        category_name
        id
      }
      ventreplies(order_by: {created_at: desc}) {
        reply
      }
      ventreplies_aggregate {
        aggregate {
          count
        }
      }
    }
  }
''';

const String getVentsByCategoryQuery = '''
  query GetVentsByCategory(\$categoryId: uuid!) {
    vent(
      order_by: [{ created_at: desc }]
      where: { vent_category: { id: { _eq: \$categoryId } } }
    ) {
      content
      created_at
      id
      updated_at
      user_id
      user {
        id
        username
        profile_image
      }
      vent_category {
        category_name
        id
      }
      ventreplies(order_by: {created_at: desc}) {
        reply
      }
      ventreplies_aggregate {
        aggregate {
          count
        }
      }
    }
  }
''';