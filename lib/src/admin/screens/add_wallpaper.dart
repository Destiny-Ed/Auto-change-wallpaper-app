import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/src/admin/provider/admin_provider.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/configs/extensions.dart';
import 'package:wallpaper_app/shared/dialog/message_dialog.dart';
import 'package:wallpaper_app/shared/utils/pick_image.dart';
import 'package:wallpaper_app/shared/widgets/busy_overlay.dart';
import 'package:wallpaper_app/styles/color.dart';

class AddWallpaperScreen extends StatefulWidget {
  const AddWallpaperScreen({super.key});

  @override
  State<AddWallpaperScreen> createState() => _AddWallpaperScreenState();
}

class _AddWallpaperScreenState extends State<AddWallpaperScreen> {
  final tagsController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(builder: (context, state, child) {
      return BusyOverlay(
        show: state.viewState == ViewState.busy,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: const Text(
              "Add Wallpaper",
              style: TextStyle(color: white, fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //category name
                      const Text(
                        "Category Name",
                        style: TextStyle(color: white, fontSize: 18),
                      ),
                      10.height(),

                      GestureDetector(
                        onTap: () async {
                          final result = await context.push('/category', extra: {'is_admin': true});
                          if (result != null) {
                            state.selectedCategory = result.toString();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          height: 30,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              border: Border.all(color: white), borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            state.selectedCategory,
                            style: const TextStyle(color: white),
                          ),
                        ),
                      ),

                      20.height(),

                      //category image and image preview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  "Wallpaper Image",
                                  style: TextStyle(color: white, fontSize: 18),
                                ),
                                10.height(),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    height: 300,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: white),
                                        borderRadius: BorderRadius.circular(15)),
                                    child: IconButton(
                                      onPressed: () async {
                                        final image = await getImagePathFromSource();

                                        state.wallpaperImage = image;
                                      },
                                      icon: const Icon(
                                        Icons.upload,
                                        color: white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          20.width(),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  "Wallpaper Preview",
                                  style: TextStyle(color: white, fontSize: 18),
                                ),
                                10.height(),
                                Container(
                                  height: 300,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    image: state.wallpaperImage == null
                                        ? null
                                        : DecorationImage(
                                            image: FileImage(File(state.wallpaperImage!)), fit: BoxFit.cover),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),

                      20.height(),

                      //preview
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Wallpaper Tags",
                            style: TextStyle(color: white, fontSize: 18),
                          ),
                          10.height(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            height: 30,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                border: Border.all(color: white), borderRadius: BorderRadius.circular(10)),
                            child: TextFormField(
                              controller: tagsController,
                              readOnly: state.wallpaperTags.length >= 5 ? true : false,
                              onFieldSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  state.setWallPaperTags(value);
                                  tagsController.clear();
                                }
                              },
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(color: white),
                              decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                            ),
                          ),
                          20.height(),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 10),
                            width: MediaQuery.of(context).size.width,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: state.wallpaperTags.isEmpty ? black : white),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Wrap(
                              children: List.generate(
                                state.wallpaperTags.length,
                                (index) {
                                  final tag = state.wallpaperTags[index];
                                  return Chip(
                                    label: Text(tag),
                                    onDeleted: () {
                                      state.removeWallPaperTags(tag);
                                    },
                                    deleteIcon: const Icon(Icons.clear),
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(color: white)))),
                    onPressed: () async {
                      if (state.selectedCategory.isEmpty) {
                        ///show error message
                        showMessage(context, "Please select a category");
                        return;
                      }
                      if (state.wallpaperTags.isEmpty) {
                        //show error message
                        showMessage(context, "Please add wallpaper tags");

                        return;
                      }

                      if (state.wallpaperImage == null) {
                        ///show error message
                        showMessage(context, "Please select a wallpaper image");

                        return;
                      }

                      await state.saveWallpaper();

                      if (state.viewState == ViewState.error) {
                        //show message
                        if (context.mounted) {
                          showMessage(context, state.message);
                        }
                        return;
                      }
                      if (state.viewState == ViewState.success) {
                        //show message
                        if (context.mounted) {
                          showMessage(context, "Wallpaper was successfully saved and available for use",
                              isError: false);
                        }
                      }
                    },
                    child: const Text(
                      'Continue',
                      style: TextStyle(color: black),
                    ),
                  ),
                ),
                20.height(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
