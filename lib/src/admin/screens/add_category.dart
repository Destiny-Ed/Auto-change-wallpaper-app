import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/src/admin/provider/admin_provider.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/configs/extensions.dart';
import 'package:wallpaper_app/shared/dialog/message_dialog.dart';
import 'package:wallpaper_app/shared/utils/pick_image.dart';
import 'package:wallpaper_app/shared/widgets/busy_overlay.dart';
import 'package:wallpaper_app/styles/color.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(builder: (context, state, child) {
      return BusyOverlay(
        show: state.viewState == ViewState.busy,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: const Text(
              "Add Category",
              style: TextStyle(color: white, fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      //category name
                      const Text(
                        "Category Name",
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
                          onChanged: (value) {
                            state.categoryName = value;
                          },
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(color: white),
                          decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                        ),
                      ),

                      20.height(),

                      //category image
                      const Text(
                        "Category Image",
                        style: TextStyle(color: white, fontSize: 18),
                      ),
                      10.height(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: white),
                          image: state.categoryImage == null
                              ? null
                              : DecorationImage(
                                  image: FileImage(File(state.categoryImage!)), fit: BoxFit.cover),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            onPressed: () async {
                              final image = await getImagePathFromSource();

                              state.categoryImage = image;
                            },
                            icon: const Icon(
                              Icons.upload,
                              color: white,
                            ),
                          ),
                        ),
                      ),

                      20.height(),

                      //preview
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Category Preview",
                            style: TextStyle(color: white, fontSize: 18),
                          ),
                          10.height(),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 10),
                            height: 120,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(15),
                              image: state.categoryImage == null
                                  ? null
                                  : DecorationImage(
                                      image: FileImage(File(state.categoryImage!)), fit: BoxFit.cover),
                            ),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                state.categoryName,
                                style:
                                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: white),
                              ),
                            ),
                          ),
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
                      if (state.categoryName.isEmpty) {
                        ///show error message
                        showMessage(context, "Please select a name");
                        return;
                      }
                      if (state.categoryImage == null) {
                        //show error message
                        showMessage(context, "Please select a category image");
                        return;
                      }

                      await state.saveCategory();

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
                          showMessage(context, "Category was successfully saved and available for use",
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
