import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sub/first_page.dart';
import 'sub/second_page.dart';

void main() {
  runApp(const MyApp());
}

late TabController _controller;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '아카콘 다운로더',
      theme: ThemeData(
          primarySwatch: const MaterialColor(0xff3D414D, <int, Color>{
        50: Color(0x0f3D414D),
        100: Color(0x1f3D414D),
        200: Color(0x2f3D414D),
        300: Color(0x3f3D414D),
        400: Color(0x4f3D414D),
        500: Color(0x5f3D414D),
        600: Color(0x6f3D414D),
        700: Color(0x7f3D414D),
        800: Color(0x8f3D414D),
        900: Color(0x9f3D414D)
      })),
      home: const MyHomePage(title: '아카콘 다운로더'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

void goBack() {
  if(_controller.index == 0){
    SystemNavigator.pop(animated: true);
  }
  _controller.index = 0;
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffE0E0E0),
        body: TabBarView(
          children: const <Widget>[FirstPage(), SecondPage()],
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: TabBar(
          indicatorColor: const Color(0xff212121),
          indicatorWeight: 5,
          tabs: const <Tab>[
            Tab(
              icon: Icon(Icons.download, color: Color(0xff424242)),
            ),
            Tab(
              icon: Icon(Icons.search, color: Color(0xff424242)),
            )
          ],
          controller: _controller,
        ));
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
