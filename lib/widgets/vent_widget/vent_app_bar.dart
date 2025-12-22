import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VentAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String selectedFilter;
  final List<String> filterOptions;
  final ValueChanged<String> onFilterSelected;

  const VentAppBar({
    Key? key,
    required this.selectedFilter,
    required this.filterOptions,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final authState = ref.watch(authStateProvider);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Vent',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // PopupMenuButton<String>(
        //   initialValue: selectedFilter,
        //   onSelected: onFilterSelected,
        //   itemBuilder: (context) {
        //     return filterOptions.map((option) {
        //       return PopupMenuItem<String>(
        //         value: option,
        //         child: Text(option),
        //       );
        //     }).toList();
        //   },


        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //     child: Row(
        //       children: [
        //         Text(
        //           selectedFilter,
        //           style: const TextStyle(
        //             color: Colors.black,
        //             fontSize: 16,
        //           ),
        //         ),
        //         const Icon(
        //           Icons.arrow_drop_down,
        //           color: Colors.black,
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        const SizedBox(width: 8), // Add padding at the end
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
