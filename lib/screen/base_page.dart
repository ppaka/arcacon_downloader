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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [FirstPage(), const ArcaconPage()],
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(
              text: '다운로드',
            ),
            Tab(
              text: '목록',
            )
          ],
        ),
      ),
    );
  }
}
