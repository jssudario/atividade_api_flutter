// Converte num? (int ou double no JSON) para double?
double? _toDouble(dynamic valor) => (valor as num?)?.toDouble();

class ClimaAtual {
  final double temperatura;
  final double umidade;
  final double precipitacao;
  final double chuva;
  final double vento;

  const ClimaAtual({
    required this.temperatura,
    required this.umidade,
    required this.precipitacao,
    required this.chuva,
    required this.vento,
  });

  factory ClimaAtual.fromJson(Map<String, dynamic> json) {
    return ClimaAtual(
      temperatura: (json['temperature_2m'] as num).toDouble(),
      umidade: (json['relative_humidity_2m'] as num).toDouble(),
      precipitacao: (json['precipitation'] as num).toDouble(),
      chuva: (json['rain'] as num).toDouble(),
      vento: (json['wind_speed_10m'] as num).toDouble(),
    );
  }
}

class PrevisaoHora {
  final DateTime hora;
  final double? temperatura;
  final double? probabilidadeChuva;
  final double? precipitacao;
  final double? chuva;

  const PrevisaoHora({
    required this.hora,
    this.temperatura,
    this.probabilidadeChuva,
    this.precipitacao,
    this.chuva,
  });
}

class PrevisaoDia {
  final DateTime dia;
  final double? maxima;
  final double? minima;
  final double? precipitacao;
  final double? probabilidadeChuva;

  const PrevisaoDia({
    required this.dia,
    this.maxima,
    this.minima,
    this.precipitacao,
    this.probabilidadeChuva,
  });
}

class Previsao {
  final ClimaAtual atual;
  final List<PrevisaoHora> porHora;
  final List<PrevisaoDia> porDia;

  const Previsao({
    required this.atual,
    required this.porHora,
    required this.porDia,
  });

  factory Previsao.fromJson(Map<String, dynamic> json) {
    // A API devolve listas paralelas: hourly.time[i] combina com
    // hourly.temperature_2m[i], e assim por diante.
    final hourly = json['hourly'] as Map<String, dynamic>;
    final horas = hourly['time'] as List<dynamic>;
    final porHora = [
      for (var i = 0; i < horas.length; i++)
        PrevisaoHora(
          hora: DateTime.parse(horas[i] as String),
          temperatura: _toDouble(hourly['temperature_2m'][i]),
          probabilidadeChuva: _toDouble(hourly['precipitation_probability'][i]),
          precipitacao: _toDouble(hourly['precipitation'][i]),
          chuva: _toDouble(hourly['rain'][i]),
        ),
    ];

    final daily = json['daily'] as Map<String, dynamic>;
    final dias = daily['time'] as List<dynamic>;
    final porDia = [
      for (var i = 0; i < dias.length; i++)
        PrevisaoDia(
          dia: DateTime.parse(dias[i] as String),
          maxima: _toDouble(daily['temperature_2m_max'][i]),
          minima: _toDouble(daily['temperature_2m_min'][i]),
          precipitacao: _toDouble(daily['precipitation_sum'][i]),
          probabilidadeChuva: _toDouble(daily['precipitation_probability_max'][i]),
        ),
    ];

    return Previsao(
      atual: ClimaAtual.fromJson(json['current'] as Map<String, dynamic>),
      porHora: porHora,
      porDia: porDia,
    );
  }
}
