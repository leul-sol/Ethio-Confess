const String biographyQuery = """
query {
  biography(
    order_by: {created_at: desc}
  ) {
    id
    category
    created_at
    content
    user {
      username
      profile_image
    }
    biographylikes_aggregate {
      aggregate {
          count(columns: biography_id)
        }
    }
  }
}
""";

const String addBiographyMutation = """
mutation AddBiography(
  \$content: String!
) {
  insert_biography_one(
    object: {
      content: \$content
    }
  ) {
    id
    category
    content
    created_at
    user_id
  }
}
""";

const String getBiographyLikesQuery = """
query GetBiographyLikes(\$biographyId: uuid!) {
  biographylikes_aggregate(where: {biography_id: {_eq: \$biographyId}}) {
    aggregate {
      count
    }
  }
}
""";
const String topLikedBiographiesQuery = '''
    query GetTopLikedBiographies {
      biography(
      ) {
        id
        category
        content
        created_at
        user {
          username
          profile_image
        }
        biographylikes_aggregate {
          aggregate {
            count(columns: biography_id)
          }
        }
      }
    }
  ''';

const String getTopLikedBiographies = """
  query GetTopLikedBiographies {
    biography(order_by: { biographylikes_aggregate: { count: desc } }, limit: 3) {
      id
      category
      content
      created_at
      user {
        username
        profile_image
      }
      biographylikes_aggregate {
        aggregate {
          count(columns: biography_id)
        }
      }
    }
  }
""";

const String ventPostsQuery = """
  query ventPosts(\$userid: uuid!) {
    vent(where: { user_id: { _eq: \$userid } }) {
      id
      created_at
      content
    }
  }
""";
const String getPopularEntityByIdQuery = r'''
query GetPopularEntityById($id: uuid!) {
  biography_by_pk(id: $id) {
    id
    content
    created_at
    category 
    user {
      username
      profile_image
    }
    biographylikes_aggregate {
      aggregate {
        count
      }
    }
  }
}
''';
const String fetchUserProfileQuery = """
query GetUserProfile(\$userId: uuid!) {
  users_by_pk(id: \$userId) {
   created_at
        email
        id
        last_login
        profile_image
        updated_at
        username
  }
}
""";

const String fetchUserBiographiesQuery = """
query GetUserBiographies(\$userId: uuid!) {
  biography(where: {user_id: {_eq: \$userId}}, order_by: {created_at: desc}) {
    id
    category
    content
    created_at
    user{
      username
      profile_image
    }
    biographylikes_aggregate {
      aggregate {
        count
      }
    }
  }
}
""";

const String fetchUserVentsQuery = """
query GetUserVents(\$userId: uuid!) {
  vent(where: {user_id: {_eq: \$userId}}, order_by: {created_at: desc}) {
    id
    content
    created_at
    user {
      username
      profile_image
    }
    ventreplies_aggregate {
      aggregate {
        count
      }
    }
  }
}
""";

const String deleteVentMutation = """
mutation DeleteVent(\$ventId: uuid!) {
  delete_vent_by_pk(id: \$ventId) {
    id
  }
}
""";

const String deleteBiographyMutation = """
mutation DeleteBiography(\$biographyId: uuid!) {
  delete_biography_by_pk(id: \$biographyId) {
    id
  }
}
""";
const String updateVentMutation = """
mutation UpdateVent(\$id: uuid!, \$content: String!) {
  update_vent_by_pk(pk_columns: {id: \$id}, _set: {content: \$content}) {
    id
    content
    updated_at
  }
}
""";

const String updateBiographyMutation = """
mutation UpdateBiography(\$id: uuid!, \$content: String!) {
  update_biography_by_pk(pk_columns: {id: \$id}, _set: {content: \$content}) {
    id
    content
    updated_at
  }
}
""";
