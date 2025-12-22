const String getProfileImagesQuery = '''
  query GetProfileImages {
    profile_images(
      distinct_on: [id]
      order_by: [{}]
      where: {}
    ) {
      id
      name
      url
    }
  }
''';

const String updateUserProfileImageMutation = '''
  mutation UpdateUserProfileImage(\$userId: uuid!, \$profileImageUrl: String!) {
    update_users_by_pk(
      pk_columns: {id: \$userId}
      _set: {profile_image: \$profileImageUrl}
    ) {
      id
      username
      email
      profile_image
    }
  }
''';
