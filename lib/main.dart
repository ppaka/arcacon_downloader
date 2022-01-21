import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sub/first_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.white,
      primaryIconTheme: const IconThemeData(color: Colors.blue),
      brightness: Brightness.light,
      backgroundColor: const Color(0xFFE5E5E5),
      dividerColor: Colors.white54,
    );

    final ThemeData darkTheme = ThemeData(
      primarySwatch: Colors.grey,
      primaryColor: Colors.black,
      primaryIconTheme: const IconThemeData(color: Colors.grey),
      brightness: Brightness.dark,
      backgroundColor: const Color(0xFF212121),
      dividerColor: Colors.black12,
    );

    return MaterialApp(
      title: '아카콘 다운로더',
      theme: lightTheme.copyWith(
          colorScheme:
              lightTheme.colorScheme.copyWith(secondary: Colors.white)),
      darkTheme: darkTheme.copyWith(
          colorScheme: darkTheme.colorScheme.copyWith(secondary: Colors.white)),
      themeMode: ThemeMode.system,
      // debugShowCheckedModeBanner: false,
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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: FirstPage());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      cancelAllTasks();
      print("앱 종료됨");
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
}
