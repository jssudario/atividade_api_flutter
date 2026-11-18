import 'package:flutter/material.dart';

import 'screens/busca_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previsão do Tempo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFF8BBD0), // rosa pastel
        useMaterial3: true,
      ),
      home: const BuscaScreen(),
    );
  }
}
