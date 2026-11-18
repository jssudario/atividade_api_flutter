import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cidade.dart';
import '../models/previsao.dart';

/// Busca cidades pelo nome (API de geocoding do Open-Meteo).
Future<List<Cidade>> buscarCidades(String nome) async {
  final url = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
    'name': nome,
    'count': '10',
    'language': 'pt',
    'format': 'json',
  });
  final response = await http.get(url).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Erro ${response.statusCode} ao buscar as cidades');
  }

  final json =
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

  // Quando nada é encontrado, a API não envia a chave "results".
  final lista = (json['results'] as List<dynamic>?) ?? [];
  return lista
      .map((item) => Cidade.fromJson(item as Map<String, dynamic>))
      .toList();
}

/// Busca a previsão do tempo de uma cidade (API de forecast do Open-Meteo).
Future<Previsao> buscarPrevisao(Cidade cidade) async {
  final url = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': '${cidade.latitude}',
    'longitude': '${cidade.longitude}',
    'current': 'temperature_2m,relative_humidity_2m,precipitation,rain,'
        'wind_speed_10m',
    'hourly': 'temperature_2m,precipitation_probability,precipitation,rain',
    'daily': 'temperature_2m_max,temperature_2m_min,precipitation_sum,'
        'precipitation_probability_max',
    'timezone': 'America/Sao_Paulo',
  });
  final response = await http.get(url).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Erro ${response.statusCode} ao buscar a previsão');
  }

  final json =
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  return Previsao.fromJson(json);
}
