import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:metsnagna/models/category.dart';

part 'category_state.freezed.dart';

@freezed
class CategoryState with _$CategoryState {
  const CategoryState._(); // Added private constructor

  const factory CategoryState.initial() = _Initial;
  const factory CategoryState.loading() = _Loading;
  const factory CategoryState.loaded(List<CategoryModel> categories) = _Loaded;
  const factory CategoryState.error(String message) = _Error;

  bool get isLoading => maybeWhen(
        loading: () => true,
        orElse: () => false,
      );

  bool get hasError => maybeWhen(
        error: (_) => true,
        orElse: () => false,
      );

  List<CategoryModel> get categories => maybeWhen(
        loaded: (categories) => categories,
        orElse: () => [],
      );
}
