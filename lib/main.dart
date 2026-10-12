import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MTAlchemyApp());
}

class MTAlchemyApp extends StatelessWidget {
  const MTAlchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MT Alchemy',

      // Our MT Alchemy design system
      theme: AppTheme.lightTheme,

      // First screen
      home: const HomeScreen(),
    );
  }
}