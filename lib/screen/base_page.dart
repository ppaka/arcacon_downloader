import 'package:flutter/material.dart';
import '/screen/first_page.dart';
import '/screen/arcacon_list.dart';

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
          children: [FirstPage(), const ArcaconPage()],
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.looks_one),
            ),
            Tab(
              icon: Icon(Icons.looks_two),
            )
          ],
        ),
      ),
    );
  }
}
