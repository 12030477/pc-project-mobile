import 'package:flutter/material.dart';

import '../features/build_calculator/presentation/pages/build_calculator_page.dart';
import 'theme.dart';

class PCBuildBudgetApp extends StatelessWidget {
  const PCBuildBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Build Budget Helper',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const BuildCalculatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
