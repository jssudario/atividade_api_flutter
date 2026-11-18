class Cidade {
  final String nome;
  final String? estado;
  final String? pais;
  final double latitude;
  final double longitude;

  const Cidade({
    required this.nome,
    required this.latitude,
    required this.longitude,
    this.estado,
    this.pais,
  });

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      nome: json['name'] as String,
      estado: json['admin1'] as String?,
      pais: json['country'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// Ex.: "Minas Gerais, Brasil"
  String get descricao => [estado, pais].whereType<String>().join(', ');
}
