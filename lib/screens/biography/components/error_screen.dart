import 'package:flutter/material.dart';

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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Color(0xFF4169E1),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Oops! Something went wrong',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Text(
                    //   'Unable to load content at the moment.',
                    //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    //         color: Colors.black54,
                    //       ),
                    //   textAlign: TextAlign.center,
                    // ),
                    // const SizedBox(height: 8),
                    Text(
                      'Pull down to refresh and try again',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black38,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    // if (errorMessage.isNotEmpty) ...[
                    //   const SizedBox(height: 24),
                    //   Container(
                    //     padding: const EdgeInsets.all(16),
                    //     decoration: BoxDecoration(
                    //       color: Colors.grey[100],
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: Text(
                    //       errorMessage,
                    //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    //             color: Colors.black54,
                    //             fontFamily: 'monospace',
                    //           ),
                    //       textAlign: TextAlign.center,
                    //     ),
                    //   ),
                    // ],
                    // const SizedBox(height: 32),
                    // ElevatedButton.icon(
                    //   onPressed: onRefresh,
                    //   icon: const Icon(Icons.refresh_rounded),
                    //   label: const Text('Try Again'),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: const Color(0xFF4169E1),
                    //     foregroundColor: Colors.white,
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 24,
                    //       vertical: 12,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 