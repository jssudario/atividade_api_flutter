import 'package:flutter/material.dart';

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
      home: const Scaffold(
        body: Center(child: Text('Previsão do Tempo')),
      ),
    );
  }
}
