import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/src/authentication/provider/auth.dart';
import 'package:wallpaper_app/configs/extensions.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/src/onboarding/provider/state_provider.dart';
import 'package:wallpaper_app/shared/widgets/busy_overlay.dart';
import 'package:wallpaper_app/styles/color.dart';

class OnboardingHome extends StatefulWidget {
  const OnboardingHome({super.key});

  @override
  State<OnboardingHome> createState() => _OnboardingHomeState();
}

class _OnboardingHomeState extends State<OnboardingHome> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<OnboardingProvider, AuthProvider>(builder: (context, state, authState, child) {
      return Scaffold(
        body: BusyOverlay(
          show: authState.viewState == ViewState.busy,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 50),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    onPageChanged: (value) {
                      state.index = value;
                    },
                    children: List.generate(state.onboardingData.length, (index) {
                      final data = state.onboardingData[index];
                      return data.image.isAsset
                          ? Image.asset(data.image.imagePath)
                          : Image.network(data.image.imagePath);
                    }),
                  ),
                ),

                ///indicator
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(state.onboardingData.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircleAvatar(
                          radius: 3,
                          backgroundColor: state.index == index ? white : grey,
                        ),
                      );
                    }),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: AnimatedSwitcher(
                    duration: const Duration(seconds: 1),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0.0, -0.5), end: const Offset(0.0, 0.0))
                            .animate(animation),
                        child: child,
                      );
                    },
                    child: Text(
                      state.onboardingData[state.index].title,
                      key: ValueKey(state.onboardingData[state.index].title),
                      style: const TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(white),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: const BorderSide(color: white)))),
                          onPressed: () async {
                            await authState.googleSignIn();

                            if (authState.viewState == ViewState.error) {
                              log("Error occured while signing in");
                              return;
                            }
                            if (authState.viewState == ViewState.success) {
                              log("Welcome to the world of wonders");
                              if (context.mounted) {
                                context.go('/root');
                              }
                            }
                          },
                          child: const Text(
                            'Google',
                            style: TextStyle(color: black),
                          )),
                      40.width(),
                      TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(white),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: const BorderSide(color: white)))),
                          onPressed: () async {
                            final result = await authState.appleSignIn();

                            if (authState.viewState == ViewState.error) {
                              log("Error occured while signing in");
                              return;
                            }
                            if (authState.viewState == ViewState.success) {
                              log("Welcome to the world of wonders ::: ${result.additionalUserInfo?.isNewUser}");
                              if (context.mounted) {
                                context.go('/root');
                              }
                            }
                          },
                          child: const Text(
                            'Apple',
                            style: TextStyle(color: black),
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
