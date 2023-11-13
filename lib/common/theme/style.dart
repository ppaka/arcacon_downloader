import 'package:flutter/material.dart';

ThemeData mat3DarkTheme() {
  const seedColor = Color(0xFF4F5464);

  return ThemeData(
    fontFamily: 'NotoSansKR',
    useMaterial3: true,
    appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
    colorScheme:
        ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark),
  );
}

ThemeData mat3LightTheme() {
  const seedColor = Color(0xFF4F5464);

  return ThemeData(
    fontFamily: 'NotoSansKR',
    useMaterial3: true,
    appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
    colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor, brightness: Brightness.light),
  );
}
