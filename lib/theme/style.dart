import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_schemes.g.dart';

ThemeData testTheme() {
  const seedColor = Color(0xFF4F5464);

  return ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor, brightness: Brightness.dark),
      textTheme: GoogleFonts.notoSansNKoTextTheme(
        ThemeData.dark().textTheme,
      ));
}

ThemeData lightTheme() {
  return ThemeData(
    primarySwatch: const MaterialColor(0xFF4F5464, <int, Color>{
      50: Color.fromARGB(255, 158, 161, 170),
      100: Color.fromARGB(255, 149, 152, 162),
      200: Color.fromARGB(255, 132, 135, 147),
      300: Color.fromARGB(255, 114, 118, 131),
      400: Color.fromARGB(255, 97, 101, 115),
      500: Color.fromARGB(255, 79, 84, 100),
      600: Color.fromARGB(255, 71, 76, 90),
      700: Color.fromARGB(255, 63, 67, 80),
      800: Color.fromARGB(255, 55, 59, 70),
      900: Color.fromARGB(255, 47, 50, 60),
    }),
    primaryColor: Colors.white,
    primaryIconTheme: const IconThemeData(color: Colors.white),
    brightness: Brightness.light,
    backgroundColor: Colors.white,
    dividerColor: Colors.white54,
    colorScheme: const ColorScheme.light(
      primary: Color.fromRGBO(79, 84, 100, 1),
      secondary: Colors.white,
    ),
    appBarTheme:
        const AppBarTheme(backgroundColor: Color.fromRGBO(79, 84, 100, 1)),
  );
}

ThemeData darkTheme() {
  return ThemeData(
      primarySwatch: const MaterialColor(0xFF323232, <int, Color>{
        50: Color.fromARGB(255, 142, 142, 142),
        100: Color.fromARGB(255, 132, 132, 132),
        200: Color.fromARGB(255, 112, 112, 112),
        300: Color.fromARGB(255, 91, 91, 91),
        400: Color.fromARGB(255, 70, 70, 70),
        500: Color.fromARGB(255, 50, 50, 50),
        600: Color.fromARGB(255, 45, 45, 45),
        700: Color.fromARGB(255, 40, 40, 40),
        800: Color.fromARGB(255, 35, 35, 35),
        900: Color.fromARGB(255, 30, 30, 30),
      }),
      primaryColor: Colors.black,
      primaryIconTheme: const IconThemeData(color: Colors.white),
      brightness: Brightness.dark,
      backgroundColor: const Color.fromRGBO(36, 36, 40, 1),
      dividerColor: Colors.black12,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Color.fromRGBO(154, 152, 149, 1),
      ),
      appBarTheme:
          const AppBarTheme(backgroundColor: Color.fromRGBO(50, 50, 50, 1)));
}

ThemeData material3Test() {
  return ThemeData(
    fontFamily: 'NotoSansKR',
    useMaterial3: true,
    colorScheme: lightColorScheme,
  );
}

ThemeData material3TestDark() {
  return ThemeData(
    fontFamily: 'NotoSansKR',
    useMaterial3: true,
    colorScheme: darkColorScheme,
  );
}
