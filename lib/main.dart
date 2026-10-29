import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

// Placeholder entry point. Replaced with the full app in Task 10.
void main() {
  runApp(const _Placeholder());
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savings',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const Scaffold(body: Center(child: Text('Savings'))),
    );
  }
}
