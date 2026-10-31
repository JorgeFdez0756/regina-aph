import 'package:flutter/material.dart';

import '../core/theme/regina_theme.dart';
import '../features/welcome/presentation/welcome_page.dart';

class ReginaApp extends StatelessWidget {
  const ReginaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Las Aventuras de Regina',
      debugShowCheckedModeBanner: false,
      theme: ReginaTheme.light,
      home: const WelcomePage(),
    );
  }
}
