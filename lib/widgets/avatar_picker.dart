import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_image_provider.dart';

class AvatarPicker extends ConsumerStatefulWidget {
  final String? selectedAvatarUrl;
  final Function(String?) onAvatarChanged;

  const AvatarPicker({
    Key? key,
    this.selectedAvatarUrl,
    required this.onAvatarChanged,
  }) : super(key: key);

  @override
  ConsumerState<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends ConsumerState<AvatarPicker> {
  @override
  Widget build(BuildContext context) {
    final profileImagesAsync = ref.watch(profileImagesProvider);

    return Column(
      children: [
        // Current selected avatar display
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color.fromARGB(255, 153, 174, 239),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: widget.selectedAvatarUrl != null && widget.selectedAvatarUrl!.isNotEmpty
                ? NetworkImage(widget.selectedAvatarUrl!)
                : null,
            backgroundColor: widget.selectedAvatarUrl == null || widget.selectedAvatarUrl!.isEmpty
                ? const Color(0xFF4169E1)
                : null,
            child: widget.selectedAvatarUrl == null || widget.selectedAvatarUrl!.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        
        // Avatar selection grid
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: profileImagesAsync.when(
            data: (profileImages) {
              if (profileImages.isEmpty) {
                return const Center(
                  child: Text(
                    'No profile images available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: profileImages.length,
                itemBuilder: (context, index) {
                  final image = profileImages[index];
                  final isSelected = widget.selectedAvatarUrl == image.url;
                  
                  return GestureDetector(
                    onTap: () {
                      widget.onAvatarChanged(image.url);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                              ? const Color.fromARGB(255, 153, 174, 239)
                              : Colors.transparent,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage: NetworkImage(image.url),
                        backgroundColor: Colors.grey.shade200,
                        onBackgroundImageError: (exception, stackTrace) {
                          // Handle image loading error
                        },
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4169E1),
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 32,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading images',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(profileImagesProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Retry', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a profile image',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
} 