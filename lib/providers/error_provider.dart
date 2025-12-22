import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/error/app_error.dart';

final errorProvider = StateNotifierProvider<ErrorNotifier, AppError?>((ref) {
  return ErrorNotifier();
});

class ErrorNotifier extends StateNotifier<AppError?> {
  ErrorNotifier() : super(null);

  void setError(AppError error) {
    state = error;
  }

  void clearError() {
    state = null;
  }
} 