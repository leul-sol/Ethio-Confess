const String featuredBiographyQuery = r'''
query featuredBios {
  featured_bios(
    distinct_on: [category]
    limit: 1
    offset: 1
    order_by: [{}]
    where: {}
  ) {
    category
    content
    created_at
    id
    like_count
    updated_at
    user_id
    user {
      id
      username
      profile_image
    }
  }
}
''';

const String biographyWithLikesQuery = r'''
query biographyWithLikes {
  biography_with_likes {
    category
    content 
    created_at
    id
    total_like_count
    updated_at
    user_id
    user {
      id
      username
      profile_image
    }
  }
} 
''';


