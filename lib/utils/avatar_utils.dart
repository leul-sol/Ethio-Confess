import 'package:flutter/material.dart';

class AvatarUtils {
  /// Check if the given profile image is a network URL
  static bool isNetworkImage(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) {
      return false;
    }
    return profileImage.startsWith('http://') || profileImage.startsWith('https://');
  }

  /// Get the appropriate image provider for a profile image
  static ImageProvider? getProfileImage(String? profileImage) {
    if (isNetworkImage(profileImage)) {
      return NetworkImage(profileImage!);
    }
    return null;
  }

  /// Get a default avatar image provider (fallback)
  static ImageProvider? getDefaultAvatar() {
    // Return null to use a placeholder icon instead of an asset
    // This prevents issues if the asset doesn't exist
    return null;
  }

  /// Get the display name for a profile image (for accessibility)
  static String getProfileImageName(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) {
      return 'Default Avatar';
    }
    if (isNetworkImage(profileImage)) {
      // Extract name from URL or return a generic name
      return 'Profile Image';
    }
    return 'Avatar';
  }
} 