import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import 'theme.dart';

class GrillPointApp extends StatefulWidget {
  const GrillPointApp({super.key});

  @override
  State<GrillPointApp> createState() => _GrillPointAppState();
}

class _GrillPointAppState extends State<GrillPointApp> {
  ThemeMode themeMode = ThemeMode.system;

  void changeTheme(ThemeMode mode) {
    setState(() {
      themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GrillPoint',

      theme: GrillPointTheme.lightTheme,
      darkTheme: GrillPointTheme.darkTheme,
      themeMode: themeMode,

      home: HomeScreen(themeMode: themeMode, onThemeChanged: changeTheme),
    );
  }
}
