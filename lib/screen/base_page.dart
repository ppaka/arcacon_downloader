import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../screen/first_page.dart';
import '../screen/arcacon_list.dart';
// import '../screen/arcacon_alert.dart';

late FToast fToast;
int _length = 2;

showToast(Color color, IconData icon, String text, Duration? duration) {
  duration ??= const Duration(seconds: 2);

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: color,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(
          width: 12.0,
        ),
        Text(text),
      ],
    ),
  );

  fToast.removeCustomToast();

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: duration,
  );
}

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
    super.initState();
    _controller = TabController(length: _length, vsync: this);
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
      length: _length,
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
              Expanded(
                child: TabBarView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    FirstPage(),
                    // ArcaconAlert(),
                    ArcaconPage(),
                  ],
                ),
              )
            ],
          ),
          bottomNavigationBar: MediaQuery.of(context).size.width < 640
              ? NavigationBar(
                  height: 65,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
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
                      selectedIcon: Icon(Icons.download),
                      icon: Icon(Icons.download_outlined),
                      label: '다운로드',
                      tooltip: '',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.explore),
                      icon: Icon(Icons.explore_outlined),
                      label: '탐색',
                      tooltip: '',
                    ),
                  ],
                )
              : null),
    );
  }
}
