import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/styles/color.dart';

class WallpaperWidget extends StatelessWidget {
  final String url;
  final VoidCallback onTap;
  final bool isLocal;
  const WallpaperWidget({super.key, required this.url, required this.onTap, this.isLocal = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
              image: isLocal ? FileImage(File(url)) : CachedNetworkImageProvider(url) as ImageProvider,
              fit: BoxFit.cover),
        ),
      ),
    );
  }
}
