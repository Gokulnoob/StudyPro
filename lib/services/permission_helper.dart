import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionHelper {
  static Future<bool> requestStoragePermissions() async {
    try {
      // Check if we're on Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Request storage permissions
        final status = await Permission.storage.request();

        if (status.isGranted) {
          debugPrint('Storage permission granted');
          return true;
        } else if (status.isPermanentlyDenied) {
          debugPrint('Storage permission permanently denied');
          // Open app settings
          await openAppSettings();
          return false;
        } else {
          debugPrint('Storage permission denied');
          return false;
        }
      }

      // iOS and other platforms don't need explicit storage permissions for app documents
      return true;
    } catch (e) {
      debugPrint('Error requesting storage permissions: $e');
      return false;
    }
  }

  static Future<bool> checkStoragePermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.storage.status;
        return status.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint('Error checking storage permissions: $e');
      return false;
    }
  }

  static Future<void> showPermissionDialog() async {
    // This would show a dialog explaining why storage permission is needed
    // For now, just log the message
    debugPrint(
        'Storage permission is required for saving study groups locally');
  }
}
