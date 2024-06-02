import 'package:arcacon_downloader/screen/arcacon_alert.dart';
import 'package:arcacon_downloader/screen/arcacon_list.dart';
import 'package:arcacon_downloader/screen/first_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

late FToast fToast;
late List<Widget> pages;
bool isGooglePlay = false;

class BasePage extends ConsumerStatefulWidget {
  const BasePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<BasePage> createState() => _BasePageState();
}

class _BasePageState extends ConsumerState<BasePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      cancelAllTasks();
    }
  }

  @override
  void initState() {
    super.initState();
    pages = [
      FirstPage(
        parentRef: ref,
      ),
      if (isGooglePlay == true)
        const ArcaconAlert()
      else
        ArcaconPage(
          parentRef: ref,
        )
    ];
    _controller = TabController(length: pages.length, vsync: this);
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  late TabController _controller;
  late int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: pages.length,
      initialIndex: 0,
      child: Scaffold(
        body: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 640)
              NavigationRail(
                onDestinationSelected: (value) {
                  if (currentPageIndex == value && value == 1) {
                    scrollToZero();
                  }
                  setState(() {
                    currentPageIndex = value;
                    _controller.animateTo(currentPageIndex);
                  });
                },
                selectedIndex: currentPageIndex,
                labelType: NavigationRailLabelType.all,
                destinations: const <NavigationRailDestination>[
                  NavigationRailDestination(
                    selectedIcon: Icon(Icons.home_rounded),
                    icon: Icon(Icons.home_outlined),
                    label: Text('홈'),
                  ),
                  NavigationRailDestination(
                    selectedIcon: Icon(Icons.explore_rounded),
                    icon: Icon(Icons.explore_outlined),
                    label: Text('탐색'),
                  ),
                ],
              ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
            )
          ],
        ),
        bottomNavigationBar: MediaQuery.of(context).size.width < 640
            ? NavigationBar(
                height: 70,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (value) {
                  if (currentPageIndex == value && value == 1) {
                    scrollToZero();
                  }
                  setState(() {
                    currentPageIndex = value;
                    _controller.animateTo(currentPageIndex);
                  });
                },
                selectedIndex: currentPageIndex,
                destinations: const <Widget>[
                  NavigationDestination(
                    selectedIcon: Icon(Icons.home_rounded),
                    icon: Icon(Icons.home_outlined),
                    label: '홈',
                    tooltip: '',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.explore_rounded),
                    icon: Icon(Icons.explore_outlined),
                    label: '탐색',
                    tooltip: '',
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
