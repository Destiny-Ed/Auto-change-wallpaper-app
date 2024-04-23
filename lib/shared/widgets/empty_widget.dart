import 'package:flutter/material.dart';
import 'package:wallpaper_app/configs/extensions.dart';
import 'package:wallpaper_app/styles/color.dart';

class EmtpyWidget extends StatelessWidget {
  final String title;
  const EmtpyWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/empty.png',
              width: MediaQuery.of(context).size.width / 2,
            ),
            20.height(),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: white),
            ),
          ],
        ),
      ),
    );
  }
}
