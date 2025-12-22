import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/vent_provider.dart';
import '../error_display_widget.dart';
import 'vent_grid_item.dart';
import '../../utils/error_handler.dart';

class VentGrid extends ConsumerWidget {
  final String? categoryId;

  const VentGrid({
    Key? key,
    this.categoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventState = ref.watch(ventProvider(categoryId));

    return ventState.when(
      data: (vents) {
        if (vents.isEmpty) {
          return const Center(
            child: Text('No vents yet. Be the first to share!'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(ventProvider(categoryId).notifier).refresh();
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: vents.length,
            itemBuilder: (context, index) => VentGridItem(vent: vents[index]),
          ),
        );
      },
      loading: () => const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: Color(0xFF4169E1),
            strokeWidth: 2,
          ),
        ),
      ),
      error: (error, stackTrace) {
        String errorMessage = 'An error occurred, please try again later.';
        bool isNetwork = false;
        if (error is AppError) {
          ErrorHandle.logError(error);
          errorMessage = ErrorHandle.getErrorMessage(error);
          if (error.errorType == ErrorType.network) {
            isNetwork = true;
            errorMessage = 'No internet connection. Please check your connection and try again.';
          }
        }
        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(ventProvider(categoryId).notifier).refresh();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.18),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Color(0xFF4169E1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isNetwork ? 'Unable to load vents' : 'Unable to load vents',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pull down to refresh the page',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
