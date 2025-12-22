import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? imageUrl;
  final Function(String?) onImageChanged;

  const ProfileImagePicker({Key? key, this.imageUrl, required this.onImageChanged}) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  bool _uploading = false;

  Future<void> _pickAndUpload() async {
    print('=== PROFILE IMAGE PICKER START ===');
    final picker = ImagePicker();
    print('Image picker initialized');
    
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    print('Image picked: ${picked != null ? 'Yes' : 'No'}');
    
    if (picked != null) {
      print('Selected image path: ${picked.path}');
      print('Selected image name: ${picked.name}');
      print('Selected image size: ${picked.length} bytes');
      
      setState(() => _uploading = true);
      print('Upload state set to true');
      print('Starting image upload to Cloudinary...');
      
      try {
        print('Calling CloudinaryService.uploadImage...');
        final url = await CloudinaryService.uploadImage(File(picked.path));
        print('Cloudinary upload completed');
        print('Upload result: url = ${url ?? 'null'}');
        
        setState(() => _uploading = false);
        print('Upload state set to false');
        
        if (url != null) {
          print('Calling onImageChanged with URL: $url');
          widget.onImageChanged(url);
          print('onImageChanged callback completed');
        } else {
          print('Upload returned null.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image upload failed. Please try again.'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        print('=== PROFILE IMAGE UPLOAD ERROR ===');
        print('Upload error: $e');
        print('Error type: ${e.runtimeType}');
        setState(() => _uploading = false);
        print('Upload state set to false after error');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image upload error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      print('No image selected');
    }
    print('=== PROFILE IMAGE PICKER END ===');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Color.fromARGB(255, 153, 174, 239),
              width: 2,
            ),
          ),
          child: widget.imageUrl != null
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(widget.imageUrl!),
                )
              : Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 52,
                    color: Color(0xFF4169E1),
                  ),
                ),
        ),
        if (_uploading)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Row(
            children: [
              GestureDetector(
                onTap: _uploading ? null : _pickAndUpload,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(0xFF4169E1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              if (widget.imageUrl != null)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: _uploading ? null : () => widget.onImageChanged(null),
                ),
            ],
          ),
        ),
      ],
    );
  }
} 