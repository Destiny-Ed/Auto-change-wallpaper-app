import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/configs/extensions.dart';
import 'package:wallpaper_app/shared/dialog/message_dialog.dart';
import 'package:wallpaper_app/src/authentication/provider/auth.dart';
import 'package:wallpaper_app/src/settings/provider/settings_provider.dart';
import 'package:wallpaper_app/styles/color.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();

    final stateProvider = Provider.of<SettingsProvider>(context, listen: false);

    stateProvider.getAutoChangeInterval();

    stateProvider.getAppVersion();

    stateProvider.getWallpaperLocation();

    stateProvider.getAutoChangeWallpapersList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(builder: (context, settingsState, child) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Auto Change Wallpaper',
                    style: TextStyle(color: white, fontSize: 18),
                  ),
                  20.height(),
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: const Text(
                      'Select Intervals',
                      style: TextStyle(color: white),
                    ),
                    subtitle: Text(settingsState.selectedDuration.inMinutes < 1
                        ? "Set Intervals"
                        : "${settingsState.selectedDuration.inMinutes} minutes"),
                    trailing: Switch.adaptive(
                        value: settingsState.selectedDuration.inMinutes >= 1,
                        onChanged: (value) {
                          if (settingsState.selectedDuration.inMinutes < 1) {
                            showIntervalDialog(settingsState);
                          } else {
                            settingsState.setAutoChangeInterval(const Duration(minutes: 0));
                          }
                        }),
                    onTap: () {
                      showIntervalDialog(settingsState);
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: const Text(
                      "Select Auto Change Wallpapers",
                      style: TextStyle(color: white),
                    ),
                    subtitle: Text("${settingsState.autoChangeWallpaperList.length} selected"),
                    onTap: () async {
                      await context.push('/downloads', extra: true);

                      settingsState.saveAutoChangeWallpaper(settingsState.autoChangeWallpaperList);
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: const Text(
                      "Downloads",
                      style: TextStyle(color: white),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: white,
                    ),
                    leading: const Icon(
                      Icons.download,
                      color: white,
                    ),
                    onTap: () {
                      context.push('/downloads');
                    },
                  ),
                  20.height(),
                  TextButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(primaryColor),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), side: const BorderSide(color: white)))),
                    onPressed: () async {
                      final provider = Provider.of<AuthProvider>(context, listen: false);

                      await provider.signOut();

                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                    child: const Text(
                      'Log Out',
                      style: TextStyle(color: white),
                    ),
                  ),
                  (MediaQuery.of(context).size.height ~/ 2.5).height(),
                  Text(
                    "Current Version v${settingsState.appVersion}",
                    style: const TextStyle(color: white),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void showIntervalDialog(SettingsProvider settingsState) {
    if (settingsState.autoChangeWallpaperList.length < 2) {
      showMessage(
        context,
        "Please select more than 1 wallpapers to automatically change from downloads",
        onConfirmTapped: () async {
          await context.push('/downloads', extra: true);

          ///Save after selection
          settingsState.saveAutoChangeWallpaper(settingsState.autoChangeWallpaperList);
        },
      );
      return;
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Select Auto Change Interval And Location",
              textAlign: TextAlign.center,
            ),
            content: StatefulBuilder(builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(settingsState.getIntervalList().length, (index) {
                    final data = settingsState.getIntervalList()[index];
                    final text = "${data.inMinutes} minutes";
                    return GestureDetector(
                      onTap: () {
                        settingsState.setAutoChangeInterval(data);
                        state(() {});
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Expanded(child: Text(text)),
                            if (data.inMinutes == settingsState.selectedDuration.inMinutes)
                              const Icon(Icons.check),
                          ],
                        ),
                      ),
                    );
                  }),
                  20.height(),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...List.generate(settingsState.wallpaperLocationList.length, (index) {
                          final data = settingsState.wallpaperLocationList[index];
                          return GestureDetector(
                            onTap: () {
                              settingsState.setWallpaperLocation(data);
                              state(() {});
                            },
                            child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      settingsState.selectedWallpaperLocation == data ? primaryColor : grey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  "${settingsState.returnLocationNameFromInt(data)} Screen",
                                  style: const TextStyle(color: white),
                                )),
                          );
                        }),
                      ],
                    ),
                  ),
                  10.height(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(primaryColor),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: const BorderSide(color: white)))),
                      onPressed: () async {
                        context.pop();
                      },
                      child: const Text(
                        'Okay',
                        style: TextStyle(color: white),
                      ),
                    ),
                  ),
                ],
              );
            }),
          );
        });
  }
}
