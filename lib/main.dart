import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const StudySessionLogApp());
}

class StudySessionLogApp extends StatelessWidget {
  const StudySessionLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Session Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const SplashScreen(),
    );
  }
}
