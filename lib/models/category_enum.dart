// This file defines the Category enum used by the existing providers
enum Category {
  Family,
  Relationship,
  Health,
  Happiness,
  All,
  Gratitude,
  LoveAndAffection,
  PrideAndAccomplishment,
  HopeAndMotivation,
  SadnessAndDepression,
  LonelinessAndIsolation,
  LossAndGrief,
  InsecurityAndSelfDoubt,
  Overthinking,
  MoneyProblems,
  WorkAndCareer,
}

// Convert CategoryModel to Category enum
Category categoryModelToEnum(String categoryName) {
  // First trim the input
  final trimmedName = categoryName.trim();

  // Create a direct mapping for known categories
  const categoryMap = {
    'Family': Category.Family,
    'Relationship': Category.Relationship,
    'Health': Category.Health,
    'Happiness': Category.Happiness,
    'All': Category.All,
    'Gratitude': Category.Gratitude,
    'Love & Affection': Category.LoveAndAffection,
    'Pride & Accomplishment': Category.PrideAndAccomplishment,
    'Hope & Motivation': Category.HopeAndMotivation,
    'Sadness & Depression': Category.SadnessAndDepression,
    'Loneliness & Isolation': Category.LonelinessAndIsolation,
    'Loss & Grief': Category.LossAndGrief,
    'Insecurity & Self-Doubt': Category.InsecurityAndSelfDoubt,
    'Overthinking': Category.Overthinking,
    'Money Problems': Category.MoneyProblems,
    'Work & Career': Category.WorkAndCareer,
  };

  // Try direct lookup first
  if (categoryMap.containsKey(trimmedName)) {
    return categoryMap[trimmedName]!;
  }

  // Normalize the category name by removing special characters and spaces
  final normalized = categoryName
      .replaceAll('&', 'And')
      .replaceAll('-', '')
      .replaceAll(' ', '')
      .trim();

  try {
    // Try to find a matching enum value
    return Category.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            normalized.toLowerCase(), orElse: () {
      // Handle special cases that don't follow the pattern
      switch (categoryName.trim()) {
        case "Family":
          return Category.Family;
        case "Relationship":
          return Category.Relationship;
        case "Health":
          return Category.Health;
        case "Happiness":
          return Category.Happiness;
        case "All":
          return Category.All;
        case "Gratitude":
          return Category.Gratitude;
        case "Love & Affection":
          return Category.LoveAndAffection;
        case "Pride & Accomplishment":
        case "Pride & Accomplishment ": // Note the extra space
          return Category.PrideAndAccomplishment;
        case "Hope & Motivation":
          return Category.HopeAndMotivation;
        case "Sadness & Depression":
          return Category.SadnessAndDepression;
        case "Loneliness & Isolation":
          return Category.LonelinessAndIsolation;
        case "Loss & Grief":
          return Category.LossAndGrief;
        case "Insecurity & Self-Doubt":
        case "Insecurity & Self-Doubt ": // Note the extra space
          return Category.InsecurityAndSelfDoubt;
        case "Overthinking":
          return Category.Overthinking;
        case "Money Problems":
        case "Money Problems ": // Note the extra space
          return Category.MoneyProblems;
        case "Work & Career":
          return Category.WorkAndCareer;
        default:
          print("Warning: No matching enum for category: $categoryName");
          return Category.Family; // Default fallback
      }
    });
  } catch (e) {
    print("Error in categoryModelToEnum: $e for category: $categoryName");
    return Category.Family; // Default fallback
  }
}

// Convert Category enum to String
String categoryToString(Category category) {
  switch (category) {
    case Category.Family:
      return "Family";
    case Category.Relationship:
      return "Relationship";
    case Category.Health:
      return "Health";
    case Category.Happiness:
      return "Happiness";
    case Category.All:
      return "All";
    case Category.Gratitude:
      return "Gratitude";
    case Category.LoveAndAffection:
      return "Love & Affection";
    case Category.PrideAndAccomplishment:
      return "Pride & Accomplishment";
    case Category.HopeAndMotivation:
      return "Hope & Motivation";
    case Category.SadnessAndDepression:
      return "Sadness & Depression";
    case Category.LonelinessAndIsolation:
      return "Loneliness & Isolation";
    case Category.LossAndGrief:
      return "Loss & Grief";
    case Category.InsecurityAndSelfDoubt:
      return "Insecurity & Self-Doubt";
    case Category.Overthinking:
      return "Overthinking";
    case Category.MoneyProblems:
      return "Money Problems";
    case Category.WorkAndCareer:
      return "Work & Career";
    default:
      return category.toString().split('.').last;
  }
}

// Convert Category enum to GraphQL enum string
String categoryToGraphQLEnum(Category category) {
  // Try uppercase versions of the category names
  switch (category) {
    case Category.Family:
      return "Family";
    case Category.Relationship:
      return "Relationship";
    case Category.Health:
      return "Health";
    case Category.Happiness:
      return "Happiness";
    case Category.All:
      return "All";
    case Category.Gratitude:
      return "Gratitude";
    case Category.LoveAndAffection:
      return "Love & Affection";
    case Category.PrideAndAccomplishment:
      return "Pride & Accomplishment";
    case Category.HopeAndMotivation:
      return "Hope & Motivation";
    case Category.SadnessAndDepression:
      return "Sadness & Depression";
    case Category.LonelinessAndIsolation:
      return "Loneliness & Isolation";
    case Category.LossAndGrief:
      return "Loss & Grief";
    case Category.InsecurityAndSelfDoubt:
      return "Insecurity & Self-Doubt";
    case Category.Overthinking:
      return "Overthinking";
    case Category.MoneyProblems:
      return "Money Problems";
    case Category.WorkAndCareer:
      return "Work & Career";
    default:
      return "Relationship";
  }
}
