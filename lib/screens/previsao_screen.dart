import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../models/previsao.dart';
import '../services/clima_service.dart';

class PrevisaoScreen extends StatefulWidget {
  final Cidade cidade;

  const PrevisaoScreen({super.key, required this.cidade});

  @override
  State<PrevisaoScreen> createState() => _PrevisaoScreenState();
}

class _PrevisaoScreenState extends State<PrevisaoScreen> {
  late Future<Previsao> _futurePrevisao;

  @override
  void initState() {
    super.initState();
    _futurePrevisao = buscarPrevisao(widget.cidade); // chamado uma única vez
  }

  Future<void> _recarregar() async {
    final future = buscarPrevisao(widget.cidade);
    setState(() => _futurePrevisao = future);
    try {
      await future;
    } catch (_) {
      // o erro é exibido pelo FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cidade.nome),
        actions: [
          IconButton(
            onPressed: _recarregar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: FutureBuilder<Previsao>(
        future: _futurePrevisao,
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
                      onPressed: _recarregar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3) Dados
          final previsao = snapshot.data;
          if (previsao == null) {
            return const Center(child: Text('Nenhuma previsão encontrada.'));
          }

          return RefreshIndicator(
            onRefresh: _recarregar,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CartaoAtual(cidade: widget.cidade, atual: previsao.atual),
                const SizedBox(height: 24),
                const Text('Próximas horas', style: _titulo),
                const SizedBox(height: 8),
                _ListaHoras(horas: _proximasHoras(previsao.porHora)),
                const SizedBox(height: 24),
                const Text('Próximos dias', style: _titulo),
                const SizedBox(height: 8),
                for (final dia in previsao.porDia) _LinhaDia(dia: dia),
              ],
            ),
          );
        },
      ),
    );
  }

  // As 24 horas a partir da hora atual.
  List<PrevisaoHora> _proximasHoras(List<PrevisaoHora> horas) {
    final agora = DateTime.now();
    final inicio = DateTime(agora.year, agora.month, agora.day, agora.hour);
    return horas.where((h) => !h.hora.isBefore(inicio)).take(24).toList();
  }
}

const _titulo = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

// "20.3" -> "20.3°C"; nulo -> "--"
String _fmt(double? valor, String unidade) =>
    valor == null ? '--' : '${valor.toStringAsFixed(1)}$unidade';

String _doisDigitos(int n) => n.toString().padLeft(2, '0');

const _diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

class _CartaoAtual extends StatelessWidget {
  final Cidade cidade;
  final ClimaAtual atual;

  const _CartaoAtual({required this.cidade, required this.atual});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(cidade.descricao),
            const SizedBox(height: 8),
            Text(
              _fmt(atual.temperatura, '°C'),
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Info(Icons.water_drop, 'Umidade', _fmt(atual.umidade, '%')),
                _Info(Icons.grain, 'Chuva', _fmt(atual.chuva, ' mm')),
                _Info(Icons.air, 'Vento', _fmt(atual.vento, ' km/h')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const _Info(this.icone, this.rotulo, this.valor);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icone),
        const SizedBox(height: 4),
        Text(rotulo, style: const TextStyle(fontSize: 12)),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ListaHoras extends StatelessWidget {
  final List<PrevisaoHora> horas;

  const _ListaHoras({required this.horas});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: horas.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final h = horas[index];
          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${_doisDigitos(h.hora.hour)}h'),
                  const SizedBox(height: 6),
                  Text(
                    _fmt(h.temperatura, '°'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${h.probabilidadeChuva?.round() ?? '--'}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LinhaDia extends StatelessWidget {
  final PrevisaoDia dia;

  const _LinhaDia({required this.dia});

  @override
  Widget build(BuildContext context) {
    final data = '${_diasSemana[dia.dia.weekday - 1]} '
        '${_doisDigitos(dia.dia.day)}/${_doisDigitos(dia.dia.month)}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(data),
        subtitle: Text(
          'Chuva: ${_fmt(dia.precipitacao, ' mm')} · '
          'prob. ${dia.probabilidadeChuva?.round() ?? '--'}%',
        ),
        trailing: Text(
          '${_fmt(dia.minima, '°')} / ${_fmt(dia.maxima, '°')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
