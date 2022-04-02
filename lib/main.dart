import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sub/first_page.dart';
import 'sub/arcacon_list.dart';

void main() {
  runApp(const MyApp());
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = ThemeData(
      primarySwatch: const MaterialColor(0xFF4F5464, <int, Color>{
        50: Color.fromARGB(1, 158, 161, 170),
        100: Color.fromARGB(1, 149, 152, 162),
        200: Color.fromARGB(1, 132, 135, 147),
        300: Color.fromARGB(1, 114, 118, 131),
        400: Color.fromARGB(1, 97, 101, 115),
        500: Color.fromARGB(1, 79, 84, 100),
        600: Color.fromARGB(1, 71, 76, 90),
        700: Color.fromARGB(1, 63, 67, 80),
        800: Color.fromARGB(1, 55, 59, 70),
        900: Color.fromARGB(1, 47, 50, 60),
      }),
      primaryColor: Colors.white,
      primaryIconTheme: const IconThemeData(color: Colors.white),
      brightness: Brightness.light,
      backgroundColor: const Color(0xFFFFFFFF),
      dividerColor: Colors.white54,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4F5464),
        secondary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF4F5464)),
    );

    final ThemeData darkTheme = ThemeData(
        primarySwatch: const MaterialColor(0xFF323232, <int, Color>{
          50: Color.fromARGB(1, 142, 142, 142),
          100: Color.fromARGB(1, 132, 132, 132),
          200: Color.fromARGB(1, 112, 112, 112),
          300: Color.fromARGB(1, 91, 91, 91),
          400: Color.fromARGB(1, 70, 70, 70),
          500: Color.fromARGB(1, 50, 50, 50),
          600: Color.fromARGB(1, 45, 45, 45),
          700: Color.fromARGB(1, 40, 40, 40),
          800: Color.fromARGB(1, 35, 35, 35),
          900: Color.fromARGB(1, 30, 30, 30),
        }),
        primaryColor: Colors.black,
        primaryIconTheme: const IconThemeData(color: Colors.white),
        brightness: Brightness.dark,
        backgroundColor: const Color(0xFF242428),
        dividerColor: Colors.black12,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFF9A9895),
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF323232)));

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 투명색
    ));

    return MaterialApp(
      title: '아카콘 다운로더',
      theme: lightTheme,
      /*lightTheme.copyWith(
          colorScheme:
          lightTheme.colorScheme.copyWith(secondary: Colors.white)),*/
      darkTheme: darkTheme,
      /*darkTheme.copyWith(
          colorScheme: darkTheme.colorScheme.copyWith(secondary: Colors.white)),*/
      themeMode: ThemeMode.system,
      // debugShowCheckedModeBanner: false,
      home: const MyPage(title: '아카콘 다운로더'),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white, body: ArcaconPage());
    //return Scaffold(backgroundColor: Colors.white, body: FirstPage());
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
