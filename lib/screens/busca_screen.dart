import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../services/clima_service.dart';
import 'previsao_screen.dart';

class BuscaScreen extends StatefulWidget {
  const BuscaScreen({super.key});

  @override
  State<BuscaScreen> createState() => _BuscaScreenState();
}

class _BuscaScreenState extends State<BuscaScreen> {
  final _controller = TextEditingController();

  // Nulo até o usuário fazer a primeira busca.
  Future<List<Cidade>>? _futureCidades;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _buscar() {
    final nome = _controller.text.trim();
    if (nome.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _futureCidades = buscarCidades(nome);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previsão do Tempo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _buscar(),
              decoration: InputDecoration(
                labelText: 'Nome da cidade',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _buscar,
                  icon: const Icon(Icons.search),
                  tooltip: 'Buscar',
                ),
              ),
            ),
          ),
          Expanded(child: _resultado()),
        ],
      ),
    );
  }

  Widget _resultado() {
    // Antes da primeira busca
    if (_futureCidades == null) {
      return const Center(child: Text('Digite o nome de uma cidade.'));
    }

    return FutureBuilder<List<Cidade>>(
      future: _futureCidades,
      builder: (context, snapshot) {
        // 1) Carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2) Erro
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Erro: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _buscar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        // 3) Dados
        final cidades = snapshot.data ?? [];
        if (cidades.isEmpty) {
          return const Center(child: Text('Nenhuma cidade encontrada.'));
        }

        return ListView.separated(
          itemCount: cidades.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final cidade = cidades[index];
            return ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(cidade.nome),
              subtitle: Text(cidade.descricao),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrevisaoScreen(cidade: cidade),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
