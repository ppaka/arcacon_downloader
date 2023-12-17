import 'package:arcacon_downloader/common/models/preview_arcacon.dart';
import 'package:arcacon_downloader/common/utils/load_item.dart';
import 'package:arcacon_downloader/common/widget/arcacon_item.dart';
import 'package:arcacon_downloader/common/widget/custom_popmenu_item.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

int lastLoadPage = 0;
int nowWorkingPage = -1;
late int lastPage;
List<PreviewArcaconItem> previewList = [];
late Future<List<PreviewArcaconItem>> items;
bool sortByRank = false;

enum SearchFilter { title, nickname, tag }

SearchFilter searchFilter = SearchFilter.title;
String searchString = "";

ScrollController? scrollController;

void scrollToZero() {
  scrollController?.animateTo(0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart);
}

class ArcaconPage extends StatefulWidget {
  const ArcaconPage({super.key, required this.parentRef});

  final WidgetRef parentRef;

  @override
  ArcaconPageState createState() => ArcaconPageState();
}

class ArcaconPageState extends State<ArcaconPage>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController searchTextController;

  Future<void> requestNew() async {
    previewList.clear();
    setState(() {
      items = loadPage(true).whenComplete(() {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          for (int i = 0; i < 5; i++) {
            if (!scrollController!.hasClients) break;
            if (scrollController!.offset >
                scrollController!.position.maxScrollExtent -
                    MediaQuery.of(context).size.height *
                        MediaQuery.of(context).devicePixelRatio) {
              await requestMore();
              setState(() {});
            }
          }
        });
      });
    });
  }

  Future<void> requestMore() async {
    await loadPage(false).onError((error, stackTrace) {
      debugPrint(error.toString());
      return previewList;
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    searchTextController = TextEditingController();
    items = loadPage(true).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        for (int i = 0; i < 5; i++) {
          if (!scrollController!.hasClients) break;
          if (!scrollController!.position.hasContentDimensions) {
            return;
          }
          if (scrollController!.offset >
              scrollController!.position.maxScrollExtent -
                  MediaQuery.of(context).size.height *
                      MediaQuery.of(context).devicePixelRatio) {
            await requestMore();
            setState(() {});
          }
        }
      });
    });

    scrollController?.addListener(() {
      if (!scrollController!.position.hasContentDimensions) {
        return;
      }
      if (scrollController!.offset >
          scrollController!.position.maxScrollExtent -
              MediaQuery.of(context).size.height *
                  MediaQuery.of(context).devicePixelRatio) {
        requestMore().then((value) => setState(() {}));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController?.dispose();
    searchTextController.dispose();
  }

  void changeSearchFilter(SearchFilter filter) {
    searchFilter = filter;
    if (searchString != "") {
      try {
        if (scrollController!.hasClients) {
          scrollController?.jumpTo(0);
        }
      } finally {
        requestNew();
      }
    }
  }

  void changeSortByRank(bool bool) {
    sortByRank = bool;
    try {
      if (scrollController!.hasClients) {
        scrollController?.jumpTo(0);
      }
    } finally {
      requestNew();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchTextController,
          onSubmitted: (value) {
            searchString = value;
            if (scrollController!.hasClients) {
              scrollController?.jumpTo(0);
            }
            requestNew();
          },
          decoration: InputDecoration(
              labelText: '검색',
              suffixIcon: IconButton(
                  onPressed: () {
                    searchString = searchTextController.text;
                    if (scrollController!.hasClients) {
                      scrollController?.jumpTo(0);
                    }
                    requestNew();
                  },
                  icon: const Icon(Icons.search))),
        ),
        actions: [
          CustomPopMenuButton(
              changeSearchFilter: changeSearchFilter,
              changeSortByRank: changeSortByRank),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: items,
          builder: (context, AsyncSnapshot<List<PreviewArcaconItem>> snapshot) {
            if (snapshot.hasData) {
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: RefreshIndicator(
                  onRefresh: requestNew,
                  child: GridView.builder(
                    controller: scrollController,
                    itemBuilder: (context, position) {
                      return ArcaconItem(
                        snapshot: snapshot,
                        position: position,
                        parentRef: widget.parentRef,
                      );
                    },
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150,
                      mainAxisSpacing: 7, //수평 Padding
                      crossAxisSpacing: 7, //수직 Padding
                      mainAxisExtent: 180,
                      //childAspectRatio: (itemWidth / itemHeight), //item 의 가로 1, 세로 2 의 비율
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              if (snapshot.data == null) {
                return Text(
                  "아무 데이터도 찾을 수 없었습니다...\n${snapshot.error}",
                  textAlign: TextAlign.center,
                );
              } else {
                return Text("${snapshot.error}");
              }
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
