import 'package:flutter/material.dart';

class GrillPointTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF58A6FF),
      onPrimary: Colors.white,

      secondary: Color(0xFF58A6FF),
      onSecondary: Colors.white,

      surface: Color(0xFF0D1117),
      onSurface: Color(0xFFE6EDF3),

      surfaceContainerHighest: Color(0xFF161B22),

      error: Color(0xFFF85149),
      onError: Colors.white,
    ),

    scaffoldBackgroundColor: Color(0xFF0D1117),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF161B22),
      foregroundColor: Color(0xFFE6EDF3),
      elevation: 0,
    ),

    cardTheme: const CardThemeData(color: Color(0xFF161B22), elevation: 0),

    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF0D1117)),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF161B22),
      border: OutlineInputBorder(),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF238636),
      foregroundColor: Colors.white,
    ),

    dividerTheme: const DividerThemeData(color: Color(0xFF30363D)),

    useMaterial3: true,
  );
}
