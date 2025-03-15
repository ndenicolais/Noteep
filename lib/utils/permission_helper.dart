import 'package:flutter/material.dart';
import 'package:noteep/widgets/custom_toast.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission(
    BuildContext context, Function onPermissionGranted) async {
  PermissionStatus notificationPermission =
      await Permission.notification.request();

  if (notificationPermission.isGranted) {
    onPermissionGranted();
  } else if (notificationPermission.isDenied) {
    if (context.mounted) {
      showErrorToast(
        context,
        'Permesso per le notifiche negato',
      );
    }
    await Future.delayed(const Duration(milliseconds: 1200));
    openAppSettings();
    throw Exception('Notification permission denied');
  } else if (notificationPermission.isPermanentlyDenied) {
    if (context.mounted) {
      showErrorToast(
        context,
        'Permesso per le notifiche permanentemente negato',
      );
    }
    await Future.delayed(const Duration(milliseconds: 1200));
    openAppSettings();
    throw Exception('Notification permission permanently denied');
  }
}
