import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/configs/extensions.dart';
import 'package:wallpaper_app/styles/color.dart';
import 'package:wallpaper_app/src/root_screen/provider/root_provider.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, state, child) {
      return Scaffold(
        body: Stack(
          children: [
            20.height(),
            state.bottomNavPages[state.index],
            if (state.index == 0)
              Positioned(
                top: 50,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    context.push('/search_screen');
                  },
                  child: const CircleAvatar(
                    child: Icon(
                      Icons.search,
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: black,
          type: BottomNavigationBarType.fixed,
          currentIndex: state.index,
          onTap: (value) {
            state.setIndex = value;
          },
          selectedItemColor: primaryColor,
          items: List.generate(
            state.bottomNavItems.length,
            (index) {
              final data = state.bottomNavItems[index];
              return BottomNavigationBarItem(
                icon: Icon(data['icon'], color: state.index == index ? primaryColor : white),
                label: data['label'],
              );
            },
          ),
        ),
      );
    });
  }
}
