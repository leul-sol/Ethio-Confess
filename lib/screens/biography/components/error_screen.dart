import 'package:flutter/material.dart';
import 'package:ethioconfess/widgets/app_error_widget.dart';

class BiographyErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRefresh;

  const BiographyErrorScreen({
    super.key,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: AppErrorWidget(
              message: 'Oops! Something went wrong',
              subtitle: 'Something went wrong. Please try again.',
              onRetry: onRefresh,
            ),
          ),
        ],
      ),
    );
  }
} 