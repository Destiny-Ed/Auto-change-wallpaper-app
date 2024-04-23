import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:wallpaper_app/src/admin/provider/admin_provider.dart';
import 'package:wallpaper_app/styles/color.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(builder: (context, state, child) {
      return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...List.generate(state.adminActionList.length, (index) {
                  final data = state.adminActionList[index];
                  return GestureDetector(
                    onTap: () {
                      // final name = {'category_name': 'category $index'};
                      // context.push('/view_category', extra: name);
                      switch (index) {
                        case 0:
                          // go to add category
                          context.push('/add_category');
                        case 1:
                          //got to wallpaper
                          context.push('/add_wallpaper');
                        case 2:
                          //got to wallpaper
                          context.push('/gallery');
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        data,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: white),
                      ),
                    ),
                  );
                }),
              ],
            )),
      );
    });
  }
}
