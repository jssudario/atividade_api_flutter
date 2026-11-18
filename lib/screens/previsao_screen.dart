import 'package:flutter/material.dart';

import '../models/cidade.dart';

// Tela provisória: será preenchida no próximo passo.
class PrevisaoScreen extends StatelessWidget {
  final Cidade cidade;

  const PrevisaoScreen({super.key, required this.cidade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cidade.nome)),
      body: Center(child: Text('Previsão de ${cidade.nome}')),
    );
  }
}
