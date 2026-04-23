import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/map_screen.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: GlutApp()));
}

class GlutApp extends StatelessWidget {
  const GlutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glut',
      theme: GlutTheme.dark,
      home: const MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}