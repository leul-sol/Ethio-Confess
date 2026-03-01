import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/vent_provider.dart';
import 'vent_grid_item.dart';
import '../../utils/error_handler.dart';
import '../../widgets/app_error_widget.dart';

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
        String message = 'Unable to load vents';
        String subtitle = 'Something went wrong. Please try again.';
        if (error is AppError) {
          ErrorHandle.logError(error);
          subtitle = ErrorHandle.getErrorMessage(error);
          if (error.errorType == ErrorType.network) {
            message = 'No connection';
            subtitle = 'Check your internet and try again.';
          }
        }
        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(ventProvider(categoryId).notifier).refresh();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.12),
              AppErrorWidget(
                message: message,
                subtitle: subtitle,
                onRetry: () async {
                  await ref.read(ventProvider(categoryId).notifier).refresh();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
