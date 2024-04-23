import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wallpaper_app/styles/color.dart';

void showApplyBottomSheet(BuildContext context,
    {VoidCallback? onHomeTapped, VoidCallback? onLockTapped, VoidCallback? onBothTapped}) {
  showModalBottomSheet(
      backgroundColor: black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.home,
                color: white,
              ),
              title: const Text(
                'Home Screen',
                style: TextStyle(color: white),
              ),
              onTap: () {
                context.pop();
                onHomeTapped!();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.screen_lock_landscape,
                color: white,
              ),
              title: const Text(
                'Lock Screen',
                style: TextStyle(color: white),
              ),
              onTap: () {
                Navigator.pop(context);
                onLockTapped!();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.screen_lock_landscape,
                color: white,
              ),
              title: const Text(
                'Both Screen',
                style: TextStyle(color: white),
              ),
              onTap: () {
                Navigator.pop(context);
                onBothTapped!();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.cancel,
                color: white,
              ),
              title: const Text(
                'Cancel',
                style: TextStyle(color: white),
              ),
              onTap: () => context.pop(context),
            ),
          ],
        );
      });
}
