import 'package:flutter/material.dart';
import '../screen/first_page.dart';
import '../screen/arcacon_list.dart';

class BasePage extends StatefulWidget {
  const BasePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage>
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
    _controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late TabController _controller;
  late int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: MediaQuery.of(context).size.width < 900
          ? Scaffold(
              body: TabBarView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [FirstPage(), const ArcaconPage()],
              ),
              bottomNavigationBar: NavigationBar(
                onDestinationSelected: (value) {
                  setState(() {
                    currentPageIndex = value;
                    _controller.animateTo(currentPageIndex);
                  });
                },
                selectedIndex: currentPageIndex,
                destinations: const <Widget>[
                  NavigationDestination(
                    selectedIcon: Icon(Icons.download_rounded),
                    icon: Icon(Icons.download_outlined),
                    label: '다운로드',
                    tooltip: '',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.explore_rounded),
                    icon: Icon(Icons.explore_outlined),
                    label: '탐색',
                    tooltip: '',
                  ),
                ],
              ),
            )
          : Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    onDestinationSelected: (value) {
                      setState(() {
                        currentPageIndex = value;
                        _controller.animateTo(currentPageIndex);
                      });
                    },
                    selectedIndex: currentPageIndex,
                    labelType: NavigationRailLabelType.selected,
                    destinations: const <NavigationRailDestination>[
                      NavigationRailDestination(
                        selectedIcon: Icon(Icons.download_rounded),
                        icon: Icon(Icons.download_outlined),
                        label: Text('다운로드'),
                      ),
                      NavigationRailDestination(
                        selectedIcon: Icon(Icons.explore_rounded),
                        icon: Icon(Icons.explore_outlined),
                        label: Text('탐색'),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  // This is the main content.
                  Expanded(
                    child: TabBarView(
                      controller: _controller,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [FirstPage(), const ArcaconPage()],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
