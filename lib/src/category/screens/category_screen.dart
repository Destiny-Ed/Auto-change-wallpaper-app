import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/src/category/provider/category_provider.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/shared/dialog/message_dialog.dart';
import 'package:wallpaper_app/shared/widgets/busy_overlay.dart';
import 'package:wallpaper_app/shared/widgets/empty_widget.dart';
import 'package:wallpaper_app/styles/color.dart';

class CategoryScreen extends StatefulWidget {
  final bool isAdmin;
  const CategoryScreen({super.key, this.isAdmin = false});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(builder: (context, state, child) {
      return BusyOverlay(
        show: state.viewState == ViewState.busy,
        child: Scaffold(
          appBar: widget.isAdmin ? AppBar() : null,
          body: (state.categories.isEmpty && state.viewState == ViewState.success)
              ? const EmtpyWidget(title: 'No Available Categories')
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView(
                    children: List.generate(state.categories.length, (index) {
                      final category = state.categories[index];
                      return GestureDetector(
                        onTap: () {
                          if (widget.isAdmin) {
                            ///pop and send back category name
                            context.pop(category.categoryName.toString());
                          } else {
                            final name = {'category_name': category.categoryName};
                            context.push('/view_category', extra: name);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 10),
                          height: 120,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(category.categoryImage), fit: BoxFit.cover),
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              category.categoryName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: white),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
        ),
      );
    });
  }

  void _getCategories() async {
    final providerState = Provider.of<CategoryProvider>(context, listen: false);

    await providerState.fetchCategory();

    if (providerState.viewState == ViewState.error) {
      if (mounted) {
        showMessage(context, providerState.message);
        return;
      }
    }
  }
}
