import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/configs/extensions.dart';
import 'package:wallpaper_app/shared/dialog/message_dialog.dart';
import 'package:wallpaper_app/shared/widgets/empty_widget.dart';
import 'package:wallpaper_app/shared/widgets/wallpaper_widget.dart';
import 'package:wallpaper_app/src/search/provider/search_provider.dart';
import 'package:wallpaper_app/styles/color.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(builder: (context, state, child) {
      return Scaffold(
        appBar: AppBar(
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 30,
            alignment: Alignment.centerLeft,
            decoration:
                BoxDecoration(border: Border.all(color: white), borderRadius: BorderRadius.circular(10)),
            child: TextFormField(
              controller: searchController,
              onChanged: (value) {
                state.searchQuery = value;
              },
              onFieldSubmitted: (value) {
                if (value.isNotEmpty) {
                  ///search wallpaper
                  _searchWallPaper(value);
                }
              },
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: white),
              decoration: const InputDecoration(isDense: true, border: InputBorder.none),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sample Search',
                      style: TextStyle(color: white),
                    ),
                    20.height(),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(state.sampleSearches.length, (index) {
                        final data = state.sampleSearches[index];

                        return GestureDetector(
                          onTap: () {
                            searchController.text = data;
                            state.searchQuery = data;

                            //search method
                            _searchWallPaper(data);
                          },
                          child: Chip(
                            label: Text(data),
                            backgroundColor: state.searchQuery == data ? black : white,
                          ),
                        );
                      }),
                    )
                  ],
                ),
              ),
              SliverFillRemaining(
                child: (state.searchResults.isEmpty && state.viewState == ViewState.success)
                    ? const EmtpyWidget(title: 'No search result')
                    : Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GridView(
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 0.6,
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10),
                          children: List.generate(state.searchResults.length, (index) {
                            final data = state.searchResults[index];
                            return WallpaperWidget(
                              url: data.wallPaperImage,
                              onTap: () {},
                            );
                          }),
                        ),
                      ),
              )
            ],
          ),
        ),
      );
    });
  }

  _searchWallPaper(String query) async {
    final providerState = Provider.of<SearchProvider>(context, listen: false);

    await providerState.search(query);

    if (providerState.viewState == ViewState.error) {
      if (mounted) {
        showMessage(context, providerState.message);
        return;
      }
    }
  }
  
  void setCategory()async {
    
  }
}
