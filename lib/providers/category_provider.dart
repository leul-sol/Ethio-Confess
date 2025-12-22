import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/graphql_client.dart';
import '../models/category.dart';
import '../core/error/app_error.dart';
import '../core/error/error_handler_service.dart';

final graphQLClientProvider = Provider<Future<GraphQLClient>>((ref) {
  return graphqlClient();
});

// Category state
class CategoryState {
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? error;

  CategoryState({
    required this.categories,
    this.isLoading = false,
    this.error,
  });

  CategoryState copyWith({
    List<CategoryModel>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Factory constructor for initial state
  factory CategoryState.initial() {
    return CategoryState(
      categories: [],
      isLoading: true,
      error: null,
    );
  }
}

// Category Notifier
class CategoryNotifier extends StateNotifier<CategoryState> {
  final Ref ref;

  CategoryNotifier(this.ref) : super(CategoryState.initial()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final client = await ref.read(graphQLClientProvider);
      final result = await client.query(
        QueryOptions(
          document: gql('''
            query GetCategories {
              vent_categories {
                id
                category_name
              }
            }
          '''),
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
      );

      if (result.hasException) {
        throw ErrorHandlerService.handleError(result.exception!);
      }

      final data = result.data?['vent_categories'] as List<dynamic>?;
      if (data == null) {
        throw AppError.notFound('Failed to fetch categories.');
      }

      final categories = data
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final appError = ErrorHandlerService.handleError(e, stackTrace);
      state = state.copyWith(
        error: appError.message,
        isLoading: false,
      );
    }
  }

  void resetState() {
    state = CategoryState.initial();
  }
}

// Provider
final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier(ref);
});

// Provider to get selected category index
final selectedCategoryIndexProvider = StateProvider<int>((ref) => 0);
