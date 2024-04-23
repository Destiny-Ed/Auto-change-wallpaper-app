import 'package:flutter/material.dart';
import 'package:wallpaper_app/styles/color.dart';

class BusyOverlay extends StatelessWidget {
  final Widget? child;
  final String title;
  final bool show;
  final int height;
  final double opacity;

  const BusyOverlay(
      {super.key,
      this.child,
      this.title = 'Please wait...',
      this.show = false,
      this.height = 0,
      this.opacity = 0.7});

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(children: <Widget>[
      child!,
      IgnorePointer(
        ignoring: !show,
        child: Opacity(
            opacity: show ? 1.0 : 0.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              color: white.withOpacity(opacity),
              //color: const Color.fromARGB(100, 0, 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(color: grey, backgroundColor: primaryColor),
                  ),
                  // const Image(
                  //   image: AssetImage("assets/logo.png"),
                  //   width: 50,
                  // ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Please wait...",
                    style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: height.toDouble(),
                  )
                ],
              ),
            )),
      ),
    ]));
  }
}
