
import 'package:flutter/material.dart';
import '../feature/pbkdf2/presentation/screens/pbkdf2_screen.dart';
import 'theme/app_theme.dart';

class Pbkdf2App extends StatelessWidget {
  const Pbkdf2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PBKDF2 Utility',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const Pbkdf2Screen(),
    );
  }
}
